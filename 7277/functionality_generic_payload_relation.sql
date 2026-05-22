DO $$
DECLARE
    new_relation_id BIGINT;
    functionality_relation_id BIGINT;
    functionality_field_id BIGINT;

    relation_id UUID;
    master_id UUID;

    v_parent_entity_id BIGINT;
    v_target_entity_id BIGINT;
BEGIN

-- =====================================================
-- ENTITY IDS
-- =====================================================

SELECT id
INTO v_parent_entity_id
FROM d_entities
WHERE table_name = 'integration_functionality';

SELECT id
INTO v_target_entity_id
FROM d_entities
WHERE table_name = 'generic_payload';

SELECT gen_random_uuid() INTO relation_id;
SELECT gen_random_uuid() INTO master_id;

-- =====================================================
-- ONE TO MANY :
-- integration_functionality -> generic_payload
-- FK :
-- generic_payload.integration_identifier
-- -> integration_functionality.identifier
-- =====================================================

INSERT INTO d_relationships(
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
    v_parent_entity_id,
    v_target_entity_id,
    'integration_functionality',
    'generic_payload',
    'One-to-Many',
    NULL,
    'integration_identifier',
    'identifier',
    NULL,
    NULL,
    'hasMany',
    FALSE,
    NOW(),
    'System',
    NOW(),
    NULL,
    relation_id,
    'generic_payload',
    'integration_functionality',
    'generic_payload',
    'generic_payload',
    'ACTIVE',
    gen_random_uuid(),
    'USER',
    master_id
WHERE NOT EXISTS (
    SELECT 1
    FROM d_relationships dr
    WHERE dr.parent_entity_id = v_parent_entity_id
      AND dr.target_entity_id = v_target_entity_id
      AND dr.foreign_key_column_name = 'integration_identifier'
)
RETURNING id INTO new_relation_id;

-- =====================================================
-- MULTI LOOKUP FIELD IN integration_functionality
-- =====================================================

INSERT INTO d_entity_fields (
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
    FROM d_entities
    WHERE table_name = 'integration_functionality'
),
field_data AS (
    SELECT * FROM (
        VALUES
        (
            'generic_payload',
            'multi lookup',
            'One-to-Many',
            NULL::INTEGER,
            'USER',
            NULL::NUMERIC,
            NULL::NUMERIC
        )
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
    FROM d_entity_fields df
    WHERE df.d_entity_id = e.id
      AND df.field_name = field_data.field_name
);

-- =====================================================
-- MANY TO ONE :
-- generic_payload -> integration_functionality
-- =====================================================

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
VALUES (
    v_target_entity_id,
    v_parent_entity_id,
    'generic_payload',
    'integration_functionality',
    'Many-to-One',
    NULL,
    'integration_identifier',
    'identifier',
    NULL,
    NULL,
    'belongsTo',
    FALSE,
    NOW(),
    'System',
    relation_id,
    'generic_payload',
    'integration_functionality',
    NULL,
    'integration_functionality',
    NULL,
    'ACTIVE',
    'USER',
    master_id
)
RETURNING id INTO functionality_relation_id;

-- =====================================================
-- SINGLE LOOKUP FIELD IN generic_payload
-- =====================================================

INSERT INTO d_entity_fields(
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
VALUES (
    'integration_functionality',
    'integration_functionality',
    FALSE,
    NULL,
    'integration_functionality',
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    v_target_entity_id,
    TRUE,
    NOW(),
    'System',
    FALSE,
    'single lookup',
    'Many-to-One',
    FALSE,
    TRUE,
    NULL,
    functionality_relation_id,
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
)
RETURNING id INTO functionality_field_id;

-- =====================================================
-- FIELD RELATIONSHIP
-- =====================================================

INSERT INTO d_fields_relationship(
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
VALUES (
    functionality_field_id,
    (
        SELECT id
        FROM d_entity_fields
        WHERE d_entity_id = v_parent_entity_id
          AND field_name = 'identifier'
    ),
    FALSE,
    NOW(),
    'System',
    NULL,
    'ACTIVE',
    'USER',
    NULL
);

END $$;