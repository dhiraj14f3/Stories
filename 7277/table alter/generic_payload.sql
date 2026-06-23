ALTER TABLE generic_payload
ADD COLUMN IF NOT EXISTS case_id BIGINT,
ADD COLUMN IF NOT EXISTS created_by VARCHAR(255),
ADD COLUMN IF NOT EXISTS definition_id BIGINT,
ADD COLUMN IF NOT EXISTS group_id BIGINT,
ADD COLUMN IF NOT EXISTS http_status BIGINT,
ADD COLUMN IF NOT EXISTS id BIGINT,
ADD COLUMN IF NOT EXISTS master_id UUID,
ADD COLUMN IF NOT EXISTS modified_by VARCHAR(255),
ADD COLUMN IF NOT EXISTS patient_id BIGINT,
ADD COLUMN IF NOT EXISTS record_status VARCHAR(1000),
ADD COLUMN IF NOT EXISTS resource_type VARCHAR(255),
ADD COLUMN IF NOT EXISTS resource_id BIGINT,
ADD COLUMN IF NOT EXISTS integration_identifier VARCHAR(255);

DO $$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM information_schema.columns
        WHERE table_schema = 'config'
          AND table_name = 'generic_payload'
          AND column_name = 'updated_at'
    ) THEN
        ALTER TABLE public.generic_payload
        RENAME COLUMN updated_at TO modified_at;
    END IF;
END $$;

-- udpated_at -to modified_at


INSERT INTO d_entities (
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
    'generic_payload' AS name,
    'generic_payload' AS singular_label,
    'generic_payloads' AS plural_label,
    'Base' AS type,
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
    'generic_payload' AS table_name,
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
    NULL AS parent_entity_id
WHERE NOT EXISTS (
    SELECT 1
    FROM d_entities
    WHERE table_name = 'generic_payload'
);


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
    WHERE table_name = 'generic_payload'
),
field_data AS (
    SELECT * FROM (
        VALUES
            ('id', 'serial', 'bigint', NULL::INTEGER, 'USER', NULL::NUMERIC, NULL::NUMERIC, 'long', NULL::varchar[]),
            ('created_by', 'single line', 'varchar', 1000::INTEGER, 'USER', NULL::NUMERIC, NULL::NUMERIC, 'varchar', NULL::varchar[]),
            ('modified_at', 'date-time', 'timestamp', NULL::INTEGER, 'USER', NULL::NUMERIC, NULL::NUMERIC, 'timestamp', NULL::varchar[]),
            ('modified_by', 'single line', 'varchar', 1000::INTEGER, 'USER', NULL::NUMERIC, NULL::NUMERIC, 'varchar', NULL::varchar[]),
            ('http_status', 'number', 'bigint', NULL::INTEGER, 'USER', NULL::NUMERIC, NULL::NUMERIC, 'long', NULL::varchar[]),
            ('request_id', 'uuid', 'uuid', 255::INTEGER, 'USER', NULL::NUMERIC, NULL::NUMERIC, 'uuid', NULL::varchar[]),
            ('request_body_json', 'jsonb', 'jsonb', NULL::INTEGER, 'USER', NULL::NUMERIC, NULL::NUMERIC, 'jsonb', NULL::varchar[]),
            ('status', 'single line', 'varchar', 1000::INTEGER, 'USER', NULL::NUMERIC, NULL::NUMERIC, 'varchar', NULL::varchar[]),
            ('request_path_params_json', 'jsonb', 'jsonb', NULL::INTEGER, 'USER', NULL::NUMERIC, NULL::NUMERIC, 'jsonb', NULL::varchar[]),
            ('request_query_params_json', 'jsonb', 'jsonb', NULL::INTEGER, 'USER', NULL::NUMERIC, NULL::NUMERIC, 'jsonb', NULL::varchar[]),
            ('request_headers_json', 'jsonb', 'jsonb', NULL::INTEGER, 'USER', NULL::NUMERIC, NULL::NUMERIC, 'jsonb', NULL::varchar[]),
            ('created_at', 'date-time', 'timestamp', NULL::INTEGER, 'USER', NULL::NUMERIC, NULL::NUMERIC, 'timestamp', NULL::varchar[]),
            ('transformed_request_body_json', 'jsonb', 'jsonb', NULL::INTEGER, 'USER', NULL::NUMERIC, NULL::NUMERIC, 'jsonb', NULL::varchar[]),
            ('response_body_json', 'jsonb', 'jsonb', NULL::INTEGER, 'USER', NULL::NUMERIC, NULL::NUMERIC, 'jsonb', NULL::varchar[]),
            ('transformed_response_body_json', 'jsonb', 'jsonb', NULL::INTEGER, 'USER', NULL::NUMERIC, NULL::NUMERIC, 'jsonb', NULL::varchar[]),
            ('definition_id', 'number', 'bigint', NULL::INTEGER, 'USER', NULL::NUMERIC, NULL::NUMERIC, 'long', NULL::varchar[]),
            ('group_id', 'number', 'bigint', NULL::INTEGER, 'USER', NULL::NUMERIC, NULL::NUMERIC, 'long', NULL::varchar[]),
            ('master_id', 'uuid', 'uuid', 255::INTEGER, 'USER', NULL::NUMERIC, NULL::NUMERIC, 'uuid', NULL::varchar[]),
            ('case_id', 'number', 'bigint', NULL::INTEGER, 'USER', NULL::NUMERIC, NULL::NUMERIC, 'long', NULL::varchar[]),
            ('patient_id', 'number', 'bigint', NULL::INTEGER, 'USER', NULL::NUMERIC, NULL::NUMERIC, 'long', NULL::varchar[]),
            ('resource_type', 'single line', 'varchar', 255::INTEGER, 'USER', NULL::NUMERIC, NULL::NUMERIC, 'varchar', NULL::varchar[]),
            ('resource_id', 'number', 'bigint', NULL::INTEGER, 'USER', NULL::NUMERIC, NULL::NUMERIC, 'long', NULL::varchar[]),
            ('record_status', 'single line', 'varchar', 1000::INTEGER, 'USER', NULL::NUMERIC, NULL::NUMERIC, 'varchar', NULL::varchar[]),
            ('integration_identifier', 'single line', 'varchar', 255::INTEGER, 'USER', NULL::NUMERIC, NULL::NUMERIC, 'varchar', NULL::varchar[]),
            ('response_error_message', 'multi line', 'varchar', 100::INTEGER, 'USER', NULL::NUMERIC, NULL::NUMERIC, 'varchar', NULL::varchar[])
    ) AS field_data (
        field_name,
        ui_data_type,
        db_data_type,
        char_limit,
        source_type,
        min_value,
        max_value,
        control_type,
        control_values
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
    current_timestamp AT TIME ZONE 'utc',
    NULL,
    current_timestamp AT TIME ZONE 'utc',
    NULL,
    FALSE,
    ui_data_type,
    db_data_type,
    FALSE,
    FALSE,
    NULL,
    control_type,
    control_values,
    FALSE,
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
    FROM d_entity_fields df
    WHERE df.d_entity_id = e.id
      AND df.field_name = field_data.field_name
);