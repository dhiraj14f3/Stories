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

    -- =====================================================
    -- ENTITY IDS
    -- =====================================================

    SELECT id
    INTO v_parent_entity_id
    FROM ${tenant_name}.d_entities
    WHERE table_name = 'integration_exchanges';

    SELECT id
    INTO v_target_entity_id
    FROM ${tenant_name}.d_entities
    WHERE table_name = 'c_patients';

    -- Reuse existing relation_identifier/master_id if relationship exists
    SELECT dr.relation_identifier, dr.master_id
    INTO relation_id, master_id
    FROM ${tenant_name}.d_relationships dr
    WHERE dr.parent_entity_id = v_target_entity_id
      AND dr.target_entity_id = v_parent_entity_id
      AND dr.relation_type = 'One-to-Many'
    LIMIT 1;

    IF relation_id IS NULL THEN
        relation_id := gen_random_uuid();
        master_id := gen_random_uuid();
    END IF;

    -- =====================================================
    -- ONE TO MANY : c_patients -> integration_exchanges
    -- =====================================================

    INSERT INTO ${tenant_name}.d_relationships(
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
        'integration_exchanges',
        'One-to-Many',
        NULL,
        'patient_id',
        'id',
        NULL,
        NULL,
        'hasMany',
        FALSE,
        NOW(),
        'System',
        NOW(),
        NULL,
        relation_id,
        'integration_exchanges',
        'patient',
        'integration_exchanges',
        'integration_exchanges',
        'ACTIVE',
        gen_random_uuid(),
        'USER',
        master_id
    WHERE NOT EXISTS (
        SELECT 1
        FROM ${tenant_name}.d_relationships dr
        WHERE dr.parent_entity_id = v_target_entity_id
          AND dr.target_entity_id = v_parent_entity_id
          AND dr.relation_type = 'One-to-Many'
    )
    RETURNING id INTO new_relation_id;

    IF new_relation_id IS NULL THEN
        SELECT id
        INTO new_relation_id
        FROM ${tenant_name}.d_relationships
        WHERE parent_entity_id = v_target_entity_id
          AND target_entity_id = v_parent_entity_id
          AND relation_type = 'One-to-Many'
        LIMIT 1;
    END IF;

    -- =====================================================
    -- MULTI LOOKUP FIELD IN c_patients
    -- =====================================================

    INSERT INTO ${tenant_name}.d_entity_fields (
        name,
        field_name,
        required,
        is_unique,
        label,
        type,
        options,
        default_value,
        description,
        field_constraints,
        d_entity_id,
        active,
        created_at,
        created_by,
        modified_at,
        modified_by,
        deleted,
        ui_data_type,
        db_data_type,
        foreign_key,
        not_storable,
        is_link_stub,
        control_type,
        control_values,
        auditable,
        char_limit,
        relation_id,
        min_value,
        max_value,
        tooltip_text,
        source_type,
        pattern,
        source_id,
        record_status
    )
    WITH entity AS (
        SELECT id, source_type
        FROM ${tenant_name}.d_entities
        WHERE table_name = 'c_patients'
    ),
    field_data AS (
        SELECT * FROM (
            VALUES
            ('integration_exchanges','multi lookup','One-to-Many',NULL::INTEGER,'USER',NULL::NUMERIC,NULL::NUMERIC)
        ) AS field_data (
            field_name,
            ui_data_type,
            db_data_type,
            char_limit,
            source_type,
            min_value,
            max_value
        )
    )
    SELECT
        field_name,
        field_name,
        FALSE,
        NULL,
        field_name,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        e.id,
        TRUE,
        NOW(),
        'System',
        NULL,
        NULL,
        FALSE,
        ui_data_type,
        db_data_type,
        FALSE,
        TRUE,
        NULL,
        'object',
        NULL,
        FALSE,
        char_limit,
        new_relation_id,
        min_value,
        max_value,
        NULL,
        e.source_type,
        NULL,
        NULL,
        'ACTIVE'
    FROM field_data
    CROSS JOIN entity e
    WHERE NOT EXISTS (
        SELECT 1
        FROM ${tenant_name}.d_entity_fields df
        WHERE df.d_entity_id = e.id
          AND df.field_name = field_data.field_name
    );

    -- =====================================================
    -- MANY TO ONE : integration_exchanges -> c_patients
    -- =====================================================

    INSERT INTO ${tenant_name}.d_relationships (
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
        'integration_exchanges',
        'c_patients',
        'Many-to-One',
        NULL,
        'patient_id',
        'id',
        NULL,
        NULL,
        'belongsTo',
        FALSE,
        NOW(),
        'System',
        relation_id,
        'integration_exchanges',
        'patient',
        NULL,
        'patient',
        NULL,
        'ACTIVE',
        'USER',
        master_id
    WHERE NOT EXISTS (
        SELECT 1
        FROM ${tenant_name}.d_relationships dr
        WHERE dr.parent_entity_id = v_parent_entity_id
          AND dr.target_entity_id = v_target_entity_id
          AND dr.relation_type = 'Many-to-One'
    )
    RETURNING id INTO patient_relation_id;

    IF patient_relation_id IS NULL THEN
        SELECT id
        INTO patient_relation_id
        FROM ${tenant_name}.d_relationships
        WHERE parent_entity_id = v_parent_entity_id
          AND target_entity_id = v_target_entity_id
          AND relation_type = 'Many-to-One'
        LIMIT 1;
    END IF;

    -- =====================================================
    -- SINGLE LOOKUP FIELD IN integration_exchanges
    -- =====================================================

    INSERT INTO ${tenant_name}.d_entity_fields(
        name,
        field_name,
        required,
        is_unique,
        label,
        type,
        options,
        default_value,
        description,
        field_constraints,
        d_entity_id,
        active,
        created_at,
        created_by,
        deleted,
        ui_data_type,
        db_data_type,
        foreign_key,
        not_storable,
        is_link_stub,
        relation_id,
        control_type,
        control_values,
        char_limit,
        auditable,
        min_value,
        max_value,
        tooltip_text,
        source_type,
        pattern,
        source_id,
        filter_criteria,
        record_status,
        dependent_fields,
        is_sensitive,
        nullable
    )
    SELECT
        'patient',
        'patient',
        FALSE,
        NULL,
        'patient',
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        v_parent_entity_id,
        TRUE,
        NOW(),
        'System',
        FALSE,
        'single lookup',
        'Many-to-One',
        FALSE,
        TRUE,
        NULL,
        patient_relation_id,
        'object',
        '{}',
        NULL,
        FALSE,
        NULL,
        NULL,
        NULL,
        'USER',
        NULL,
        NULL,
        NULL,
        'ACTIVE',
        NULL,
        NULL,
        TRUE
    WHERE NOT EXISTS (
        SELECT 1
        FROM ${tenant_name}.d_entity_fields df
        WHERE df.d_entity_id = v_parent_entity_id
          AND df.field_name = 'patient'
    )
    RETURNING id INTO patient_field_id;

    IF patient_field_id IS NULL THEN
        SELECT id
        INTO patient_field_id
        FROM ${tenant_name}.d_entity_fields
        WHERE d_entity_id = v_parent_entity_id
          AND field_name = 'patient'
        LIMIT 1;
    END IF;

    -- =====================================================
    -- FIELD RELATIONSHIP
    -- =====================================================

    INSERT INTO ${tenant_name}.d_fields_relationship(
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
        NOW(),
        'System',
        NULL,
        'ACTIVE',
        'USER',
        NULL
    FROM ${tenant_name}.d_entity_fields df
    WHERE df.d_entity_id = v_target_entity_id
      AND df.field_name = 'name'
      AND NOT EXISTS (
          SELECT 1
          FROM ${tenant_name}.d_fields_relationship fr
          WHERE fr.parent_field_id = patient_field_id
            AND fr.target_field_id = df.id
      );

END $$;
