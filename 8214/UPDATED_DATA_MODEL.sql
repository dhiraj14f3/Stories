set search_path to "fpa-1005";

DO $$
DECLARE
    new_relation_id      BIGINT;
    patient_relation_id  BIGINT;
    patient_field_id     BIGINT;
    relation_id          UUID;
    v_parent_entity_id   BIGINT;
    v_target_entity_id   BIGINT;
    master_id            UUID;
BEGIN
    SELECT id INTO v_parent_entity_id FROM d_entities WHERE table_name = 'c_patient_pharmacy';
    SELECT id INTO v_target_entity_id FROM d_entities WHERE table_name = 'c_patients';

    -- Reuse existing relation_identifier if the One-to-Many record already exists,
    -- otherwise generate a fresh UUID pair.
    SELECT dr.relation_identifier, dr.master_id
      INTO relation_id, master_id
      FROM d_relationships dr
     WHERE dr.parent_entity_id = v_target_entity_id
       AND dr.target_entity_id = v_parent_entity_id
       AND dr.relation_type    = 'One-to-Many'
     LIMIT 1;

    IF relation_id IS NULL THEN
        relation_id := gen_random_uuid();
        master_id   := gen_random_uuid();
    END IF;

    -- =========================================================
    -- 1. One-to-Many relationship (c_patients → c_patient_pharmacy)
    -- =========================================================
    INSERT INTO d_relationships (
        parent_entity_id,
        target_entity_id,
        parent_entity,
        target_entity,
        relation_type,
        join_table,
        foreign_key_column_name,
        referenced_column_name,
        inverse_foreign_key_column_name,
        inverse_referenced_column_name,
        mapped_by,
        deleted,
        created_at,
        created_by,
        modified_at,
        modified_by,
        relation_identifier,
        child_label,
        parent_label,
        name,
        label,
        record_status,
        uid,
        source_type,
        master_id
    )
    SELECT
        v_target_entity_id,
        v_parent_entity_id,
        'c_patients',
        'c_patient_pharmacy',
        'One-to-Many',
        NULL,
        'patient_id',
        'id',
        NULL,
        NULL,
        'hasMany',
        false,
        NOW(),
        'System',
        NOW(),
        NULL,
        relation_id,
        'patient_pharmacy',
        'patient',
        'patient',
        'patient_pharmacy',
        'ACTIVE',
        gen_random_uuid(),
        'USER',
        master_id
    WHERE NOT EXISTS (
        SELECT 1 FROM d_relationships dr
         WHERE dr.parent_entity_id = v_target_entity_id
           AND dr.target_entity_id = v_parent_entity_id
           AND dr.relation_type    = 'One-to-Many'
    )
    RETURNING id INTO new_relation_id;

    -- If the row already existed, fetch its id for use in the entity field below.
    IF new_relation_id IS NULL THEN
        SELECT id INTO new_relation_id
          FROM d_relationships
         WHERE parent_entity_id = v_target_entity_id
           AND target_entity_id = v_parent_entity_id
           AND relation_type    = 'One-to-Many'
         LIMIT 1;
    END IF;

    -- =========================================================
    -- 2. Multi-lookup field on c_patients (patient_pharmacy)
    -- =========================================================
    INSERT INTO d_entity_fields (
        name, field_name, required, is_unique, label, type, options, default_value,
        description, field_constraints, d_entity_id, active, created_at, created_by,
        modified_at, modified_by, deleted, ui_data_type, db_data_type, foreign_key,
        not_storable, is_link_stub, control_type, control_values, auditable, char_limit,
        relation_id, min_value, max_value, tooltip_text, source_type, pattern, source_id,
        record_status
    )
    WITH entity AS (
        SELECT id, source_type FROM d_entities WHERE table_name = 'c_patients'
    ),
    field_data (field_name, ui_data_type, db_data_type, char_limit, source_type, min_value, max_value) AS (
        VALUES ('patient_pharmacy', 'multi lookup', 'One-to-Many', NULL::INTEGER, 'USER', NULL::NUMERIC, NULL::NUMERIC)
    )
    SELECT
        fd.field_name,
        fd.field_name,
        false,
        NULL,
        fd.field_name,
        NULL, NULL, NULL, NULL, NULL,
        e.id,
        true,
        now(),
        'System',
        NULL, NULL,
        false,
        fd.ui_data_type,
        fd.db_data_type,
        false,
        true,
        NULL,
        'object',
        NULL,
        false,
        fd.char_limit,
        new_relation_id,
        fd.min_value,
        fd.max_value,
        NULL,
        e.source_type,
        NULL, NULL,
        'ACTIVE'
    FROM field_data fd
    CROSS JOIN entity e
    WHERE NOT EXISTS (
        SELECT 1 FROM d_entity_fields df
         WHERE df.d_entity_id = e.id
           AND df.field_name  = fd.field_name
    );

    -- =========================================================
    -- 3. Many-to-One relationship (c_patient_pharmacy → c_patients)
    -- =========================================================
    INSERT INTO d_relationships (
        parent_entity_id,
        target_entity_id,
        parent_entity,
        target_entity,
        relation_type,
        join_table,
        foreign_key_column_name,
        referenced_column_name,
        inverse_foreign_key_column_name,
        inverse_referenced_column_name,
        mapped_by,
        deleted,
        created_at,
        created_by,
        relation_identifier,
        child_label,
        parent_label,
        join_table_id,
        name,
        label,
        record_status,
        source_type,
        master_id
    )
    SELECT
        v_parent_entity_id,
        v_target_entity_id,
        'c_patient_pharmacy',
        'c_patients',
        'Many-to-One',
        NULL,
        'patient_id',
        'id',
        NULL,
        NULL,
        'belongsTo',
        FALSE,
        now(),
        'System',
        relation_id,
        'patient_pharmacy',
        'Patient',
        NULL,
        'patient',
        NULL,
        'ACTIVE',
        'USER',
        master_id
    WHERE NOT EXISTS (
        SELECT 1 FROM d_relationships dr
         WHERE dr.parent_entity_id = v_parent_entity_id
           AND dr.target_entity_id = v_target_entity_id
           AND dr.relation_type    = 'Many-to-One'
    )
    RETURNING id INTO patient_relation_id;

    -- If the row already existed, fetch its id for the field insert below.
    IF patient_relation_id IS NULL THEN
        SELECT id INTO patient_relation_id
          FROM d_relationships
         WHERE parent_entity_id = v_parent_entity_id
           AND target_entity_id = v_target_entity_id
           AND relation_type    = 'Many-to-One'
         LIMIT 1;
    END IF;

    -- =========================================================
    -- 4. Single-lookup field on c_patient_pharmacy (patient)
    -- =========================================================
    INSERT INTO d_entity_fields (
        name, field_name, required, is_unique, label, type, options, default_value,
        description, field_constraints, d_entity_id, active, created_at, created_by,
        deleted, ui_data_type, db_data_type, foreign_key, not_storable, is_link_stub,
        relation_id, control_type, control_values, char_limit, auditable,
        min_value, max_value, tooltip_text, source_type, pattern,
        source_id, filter_criteria, record_status, dependent_fields, is_sensitive,
        nullable, task_code
    )
    SELECT
        'patient', 'patient', FALSE, NULL, 'patient',
        NULL, NULL, NULL, NULL, NULL,
        v_parent_entity_id,
        TRUE, now(), 'System', FALSE,
        'single lookup', 'Many-to-One',
        FALSE, TRUE, NULL,
        patient_relation_id,
        'object', '{}',
        NULL, FALSE, NULL, NULL, NULL,
        'USER', NULL, NULL, NULL,
        'ACTIVE', NULL, NULL, TRUE, NULL
    WHERE NOT EXISTS (
        SELECT 1 FROM d_entity_fields df
         WHERE df.d_entity_id = v_parent_entity_id
           AND df.field_name  = 'patient'
    )
    RETURNING id INTO patient_field_id;

    -- If the field already existed, fetch its id for the fields-relationship insert below.
    IF patient_field_id IS NULL THEN
        SELECT id INTO patient_field_id
          FROM d_entity_fields
         WHERE d_entity_id = v_parent_entity_id
           AND field_name  = 'patient'
         LIMIT 1;
    END IF;

    -- =========================================================
    -- 5. Fields relationship (patient field → name field on c_patients)
    -- =========================================================
    INSERT INTO d_fields_relationship (
        parent_field_id,
        target_field_id,
        deleted,
        created_at,
        created_by,
        field_order,
        record_status,
        source_type,
        target_global_field_id
    )
    SELECT
        patient_field_id,
        df.id,
        FALSE,
        now(),
        'System',
        NULL,
        'ACTIVE',
        'USER',
        NULL
    FROM d_entity_fields df
    WHERE df.d_entity_id = v_target_entity_id
      AND df.field_name  = 'name'
      AND NOT EXISTS (
          SELECT 1 FROM d_fields_relationship fr
           WHERE fr.parent_field_id = patient_field_id
             AND fr.target_field_id = df.id
      );

END $$;