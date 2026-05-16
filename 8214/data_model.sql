INSERT INTO "fpa-1003".d_entities (
    name,
    singular_label,
    plural_label,
    type,
    color,
    icon,
    description,
    created_by,
    created_at,
    modified_at,
    modified_by,
    version,
    json_schema,
    deleted,
    table_name,
    entity_type,
    enabled,
    source_type,
    enable_audit,
    agent_visibility,
    sla_visibility,
    queue_visibility,
    record_status,
    uid,
    extension_of_entity_id,
    parent_entity_id
)
SELECT
    'c_patient_pharmacy' AS name,
    'c_patient_pharmacy' AS singular_label,
    'c_patient_pharmacy' AS plural_label,
    'Base' AS type,   -- fixed: quoted string
    NULL AS color,
    NULL AS icon,
    NULL AS description,
    NULL AS created_by,
    current_timestamp AT TIME ZONE 'utc' AS created_at,
    current_timestamp AT TIME ZONE 'utc' AS modified_at,
    NULL AS modified_by,
    NULL AS version,
    NULL AS json_schema,
    FALSE AS deleted,
    'c_patient_pharmacy' AS table_name,
    'BASETABLE' AS entity_type,
    TRUE AS enabled,
    'USER' AS source_type,
    FALSE AS enable_audit,
    FALSE AS agent_visibility,
    FALSE AS sla_visibility,
    FALSE AS queue_visibility,
    'ACTIVE' AS record_status,
    gen_random_uuid() AS uid,
    NULL AS extension_of_entity_id,
    NULL AS parent_entity_id;

INSERT INTO "fpa-1003".d_entity_fields (
    name, field_name, required, is_unique, label, type, options, default_value,
    description, field_constraints, d_entity_id, active, created_at, created_by,
    modified_at, modified_by, deleted, ui_data_type, db_data_type, foreign_key,
    not_storable, is_link_stub, control_type, control_values, auditable, char_limit,
    relation_id, min_value, max_value, tooltip_text, source_type, pattern, source_id, record_status
)
WITH entity AS (
    SELECT id, source_type
    FROM "fpa-1003".d_entities
    WHERE table_name = 'c_patient_pharmacy'
),
     field_data AS (
         SELECT * FROM (
                           VALUES
                               ('created_at', 'date-time', 'timestamp', NULL::INTEGER, 'USER', NULL::NUMERIC, NULL::NUMERIC, NULL, NULL),
                               ('modified_at', 'date-time', 'timestamp', NULL::INTEGER, 'USER', NULL::NUMERIC, NULL::NUMERIC, NULL, NULL),
                               ('created_by', 'single line', 'varchar', 1000::INTEGER, 'USER', NULL::NUMERIC, NULL::NUMERIC, NULL, NULL),
                               ('modified_by', 'single line', 'varchar', 1000::INTEGER, 'USER', NULL::NUMERIC, NULL::NUMERIC, NULL, NULL),
                               ('id','serial','bigint',NULL::INTEGER, 'USER', NULL::NUMERIC, NULL::NUMERIC, NULL, NULL),
                               ('record_status', 'single line', 'varchar', 1000::INTEGER, 'USER', NULL::NUMERIC, NULL::NUMERIC, NULL, NULL),
                               ('distributor', 'drop down', 'varchar', 1000::INTEGER, 'USER', NULL::NUMERIC, NULL::NUMERIC, 'varchar', '{"Neovance Specialty Pharmacy"}'),
                               ('pharmacy_id', 'single line', 'varchar', 1000::INTEGER, 'USER', NULL::NUMERIC, NULL::NUMERIC, NULL, NULL),
                               ('distributor_id','number', 'bigint', NULL::INTEGER, 'USER', NULL::NUMERIC, NULL::NUMERIC, NULL, NULL),
                               ('patient_id', 'number', 'bigint', NULL::INTEGER, 'USER', NULL::NUMERIC, NULL::NUMERIC, NULL, NULL),
                               ('is_epr_retry_success', 'checkbox', 'boolean', NULL::INTEGER, 'USER', NULL::NUMERIC, NULL::NUMERIC, NULL, NULL)
                               ('status', 'drop down', 'varchar', 1000::INTEGER, 'USER', NULL::NUMERIC, NULL::NUMERIC, 'varchar', '{"ACTIVE","INACTIVE"}')
        ) AS field_data (field_name, ui_data_type, db_data_type, char_limit, source_type, min_value, max_value, control_type,
        control_values)
     )
SELECT
    field_name,
    field_name,
    false,
    NULL,
    field_name,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    e.id,
    true,
    NULL,
    NULL,
    NULL,
    NULL,
    false,
    ui_data_type,
    db_data_type,
    false,
    false,
    NULL,
    CASE WHEN db_data_type = 'bigint' THEN 'long' ELSE db_data_type END,
    control_values,
    false,
    char_limit,
    NULL,
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
    FROM "fpa-1003".d_entity_fields df
    WHERE df.d_entity_id = e.id
      AND df.field_name = field_data.field_name
);


DO $$
DECLARE
new_relation_id bigint;
patient_relation_id BIGINT;
patient_field_id BIGINT;
relation_id UUID;
v_parent_entity_id BIGINT;   -- renamed
    v_target_entity_id BIGINT;
master_id UUID;
BEGIN
SELECT id INTO v_parent_entity_id FROM "fpa-1003".d_entities WHERE table_name = 'c_patient_pharmacy';
SELECT id INTO v_target_entity_id FROM "fpa-1003".d_entities WHERE table_name = 'c_patients';
select gen_random_uuid() INTO master_id;
select gen_random_uuid() INTO relation_id;


INSERT INTO "fpa-1003".d_relationships(
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
    v_target_entity_id,                           -- parent_entity_id
    v_parent_entity_id,                           -- target_entity_id
    'c_patients',       -- parent_entity
    'c_patient_pharmacy',                     -- target_entity
    'One-to-Many',                                 -- relation_type
    NULL,                                          -- join_table (none required)
    'patient_id',                                   -- foreign_key_column_name (example: FK in target)
    'id',                                   -- referenced_column_name (column in parent view)
    NULL,                                          -- inverse_foreign_key_column_name
    NULL,                                          -- inverse_referenced_column_name
    'hasMany',                                    -- mapped_by
    false,                                        -- deleted
    NOW(),                                        -- created_at
    'System',
    NOW(),                                        -- modified_at
    NULL,                                         -- modified_by
    relation_id,                            -- relation_identifier
    'patient_pharmacy',                           -- child_label
    'patient',                         -- parent_label
    'patient',     -- name
    'patient_pharmacy',     -- label
    'ACTIVE',                                     -- record_status
    gen_random_uuid(),                            -- uid
    'USER',                                       -- source_type
    master_id                                          -- master_id
    WHERE NOT EXISTS (
    SELECT 1 FROM "fpa-1003".d_relationships dr
    WHERE dr.parent_entity_id = v_target_entity_id
      AND dr.target_entity_id = v_parent_entity_id
)
RETURNING id INTO new_relation_id;

INSERT INTO "fpa-1003".d_entity_fields (
    name, field_name, required, is_unique, label, type, options, default_value,
    description, field_constraints, d_entity_id, active, created_at, created_by,
    modified_at, modified_by, deleted, ui_data_type, db_data_type, foreign_key,
    not_storable, is_link_stub, control_type, control_values, auditable, char_limit,
    relation_id, min_value, max_value, tooltip_text, source_type, pattern, source_id, record_status
)
WITH entity AS (
    SELECT id, source_type
    FROM "fpa-1003".d_entities
    WHERE table_name = 'c_patients'
),
     field_data AS (
         SELECT * FROM (
                           VALUES
-- 🧍 Patient Details

('patient_pharmacy','multi lookup','One-to-Many',NULL::INTEGER, 'USER', NULL::NUMERIC, NULL::NUMERIC)

                       ) AS field_data (field_name, ui_data_type, db_data_type, char_limit, source_type, min_value, max_value)
     )
SELECT
    field_name,
    field_name,
    false,
    NULL,
    field_name,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    e.id,
    true,
    now(),
    'System',
    NULL,
    NULL,
    false,
    ui_data_type,
    db_data_type,
    false,
    true,
    NULL,
    'object',
    NULL,
    false,
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
    FROM "fpa-1003".d_entity_fields df
    WHERE df.d_entity_id = e.id
      AND df.field_name = field_data.field_name
);

INSERT INTO "fpa-1003".d_relationships (
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
VALUES (
           v_parent_entity_id,                                -- parent_entity_id
           v_target_entity_id,                                  -- target_entity_id
           'c_patient_pharmacy',                -- parent_entity
           'c_patients',                   -- target_entity
           'Many-to-One',                       -- relation_type
           NULL,                                -- join_table
           'patient_id',               -- foreign_key_column_name
           'id',                                -- referenced_column_name
           NULL,                                -- inverse_foreign_key_column_name
           NULL,                                -- inverse_referenced_column_name
           'belongsTo',                         -- mapped_by
           FALSE,                               -- deleted
           now(),        -- created_at
           'Syatem',                        -- created_by
           relation_id,                   -- relation_identifier
           'patient_pharmacy',                  -- child_label
           'Patient',                  -- parent_label
           NULL,                                -- join_table_id
           'patient',                                -- name
           NULL,                                -- label
           'ACTIVE',                            -- record_status
           'USER',                              -- source_type
           master_id -- master_id
       )
    RETURNING id INTO patient_relation_id;

-- =====================================================
-- INSERT: Relationship for Decision Of Review
-- =====================================================

INSERT INTO "fpa-1003".d_entity_fields(
    name, field_name, required, is_unique, label, type, options, default_value, description,
    field_constraints, d_entity_id, active, created_at, created_by, deleted,
    ui_data_type, db_data_type, foreign_key, not_storable, is_link_stub, relation_id, control_type,
    control_values, char_limit, auditable, min_value, max_value, tooltip_text, source_type, pattern,
    source_id, filter_criteria, record_status, dependent_fields, is_sensitive,
    nullable, task_code
)
VALUES (
           -- name
           'patient',
           -- field_name
           'patient',
           -- required
           FALSE,
           -- is_unique
           NULL,
           -- label
           'patient',
           -- type
           NULL,
           -- options
           NULL,
           -- default_value
           NULL,
           -- description
           NULL,
           -- field_constraints
           NULL,
           -- d_entity_id
           v_parent_entity_id,
           -- active
           TRUE,
           -- created_at
           now(),
           -- created_by
           'System',
           -- deleted
           FALSE,
           -- ui_data_type
           'single lookup',
           -- db_data_type
           'Many-to-One',
           -- foreign_key
           FALSE,
           -- not_storable
           TRUE,
           -- is_link_stub
           NULL,
           -- relation_id
           patient_relation_id,
           -- control_type
           'object',
           -- control_values
           '{}',
           -- char_limit
           NULL,
           -- auditable
           FALSE,
           -- min_value
           NULL,
           -- max_value
           NULL,
           -- tooltip_text
           NULL,
           -- source_type
           'USER',
           -- pattern
           NULL,
           -- source_id
           NULL,
           -- filter_criteria
           NULL,
           -- record_status
           'ACTIVE',
           -- dependent_fields
           NULL,
           -- dependent_fields
           NULL,
           -- is_sensitive
           NULL,
           -- nullable
           TRUE
       )
    RETURNING id INTO patient_field_id;

INSERT INTO "fpa-1003".d_fields_relationship(
    parent_field_id,          -- parent field reference
    target_field_id,          -- child field reference
    deleted,                  -- deletion flag
    created_at,               -- record creation timestamp
    created_by,               -- user who created
    field_order,              -- ordering index
    record_status,            -- record state
    source_type,              -- who created this (SYSTEM / USER)
    target_global_field_id    -- optional mapping to global field
)
VALUES (
           patient_field_id,  -- parent field ID
           (select id from "fpa-1003".d_entity_fields where d_entity_id=v_target_entity_id and field_name ='name'),                       -- target field ID
           FALSE,                      -- deleted = false
           now(),
           'System',               -- created by
           NULL,                       -- no field order
           'ACTIVE',                   -- record is active
           'USER',                     -- source type
           NULL                        -- no global field link
       );


END $$;

 