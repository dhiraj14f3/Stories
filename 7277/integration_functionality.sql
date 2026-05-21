CREATE TABLE IF NOT EXISTS integration_functionality (
    id BIGSERIAL PRIMARY KEY,
    identifier VARCHAR(255) NOT NULL UNIQUE,
    integration_name VARCHAR(255) NOT NULL,
    request_type VARCHAR(50) NOT NULL,
    group_id VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    record_status VARCHAR(20) DEFAULT 'ACTIVE'
);


INSERT INTO integration_functionality (
    identifier,
    integration_name,
    request_type,
    group_id,
    created_at,
    updated_at,
    record_status
)
SELECT *
FROM (
    VALUES
        ('sendgrid-email', 'SENDGRID', 'OUTBOUND', 1, '2026-05-12 11:27:01.311553'::timestamp, '2026-05-12 11:27:01.311553'::timestamp, 'ACTIVE'),
        ('novo-maxrte-discovery', 'MAXRTE', 'OUTBOUND', 2, '2026-05-12 11:27:01.311553'::timestamp, '2026-05-12 11:27:01.311553'::timestamp, 'ACTIVE'),
        ('novo-maxrte-transaction', 'MAXRTE', 'OUTBOUND', 2, '2026-05-12 11:27:01.311553'::timestamp, '2026-05-12 11:27:01.311553'::timestamp, 'ACTIVE'),
        ('maxrte-token', 'MAXRTE', 'OUTBOUND', 2, '2026-05-12 11:27:01.311553'::timestamp, '2026-05-12 11:27:01.311553'::timestamp, 'ACTIVE'),
        ('surescript-test', 'SURESCRIPTS', 'OUTBOUND', 3, '2026-05-12 11:27:01.311553'::timestamp, '2026-05-12 11:27:01.311553'::timestamp, 'ACTIVE'),
        ('surescript-mock', 'SURESCRIPTS', 'OUTBOUND', 3, '2026-05-12 11:27:01.311553'::timestamp, '2026-05-12 11:27:01.311553'::timestamp, 'ACTIVE'),
        ('surescript-mock-multiple', 'SURESCRIPTS', 'OUTBOUND', 3, '2026-05-12 11:27:01.311553'::timestamp, '2026-05-12 11:27:01.311553'::timestamp, 'ACTIVE'),
        ('npi-validation', 'NPI', 'OUTBOUND', 4, '2026-05-12 11:27:01.311553'::timestamp, '2026-05-12 11:27:01.311553'::timestamp, 'ACTIVE'),
        ('epr-PatientAddRequest', 'EPR', 'OUTBOUND', 5, '2026-05-12 11:27:01.311553'::timestamp, '2026-05-12 11:27:01.311553'::timestamp, 'ACTIVE'),
        ('epr-PatientSelectRequest', 'EPR', 'OUTBOUND', 5, '2026-05-12 11:27:01.311553'::timestamp, '2026-05-12 11:27:01.311553'::timestamp, 'ACTIVE'),
        ('epr-PatientQueryRequest', 'EPR', 'OUTBOUND', 5, '2026-05-12 11:27:01.311553'::timestamp, '2026-05-12 11:27:01.311553'::timestamp, 'ACTIVE'),
        ('epr-CardholderAddIdRequest', 'EPR', 'OUTBOUND', 5, '2026-05-12 11:27:01.311553'::timestamp, '2026-05-12 11:27:01.311553'::timestamp, 'ACTIVE'),
        ('epr-PatientUpdateCardholderIdRequest', 'EPR', 'OUTBOUND', 5, '2026-05-12 11:27:01.311553'::timestamp, '2026-05-12 11:27:01.311553'::timestamp, 'ACTIVE'),
        ('epr-UpdateShippingAddress', 'EPR', 'OUTBOUND', 5, '2026-05-12 11:27:01.311553'::timestamp, '2026-05-12 11:27:01.311553'::timestamp, 'ACTIVE'),
        ('migrated-PatientAddRequest', 'EPR', 'OUTBOUND', 5, '2026-05-12 11:27:01.311553'::timestamp, '2026-05-12 11:27:01.311553'::timestamp, 'ACTIVE'),
        ('migrated-PatientQueryRequest', 'EPR', 'OUTBOUND', 5, '2026-05-12 11:27:01.311553'::timestamp, '2026-05-12 11:27:01.311553'::timestamp, 'ACTIVE'),
        ('migrated-PatientUpdateTpLinkRequest', 'EPR', 'OUTBOUND', 5, '2026-05-12 11:27:01.311553'::timestamp, '2026-05-12 11:27:01.311553'::timestamp, 'ACTIVE'),
        ('mgirated-CardholderAddIdRequest', 'EPR', 'OUTBOUND', 5, '2026-05-12 11:27:01.311553'::timestamp, '2026-05-12 11:27:01.311553'::timestamp, 'ACTIVE'),
        ('experian-financial-clearance', 'EXPERIAN', 'OUTBOUND', 6, '2026-05-12 11:27:01.311553'::timestamp, '2026-05-12 11:27:01.311553'::timestamp, 'ACTIVE'),
        ('cds-putPrescriptionDocument', 'CDS', 'OUTBOUND', 7, '2026-05-12 11:27:01.311553'::timestamp, '2026-05-12 11:27:01.311553'::timestamp, 'ACTIVE')
) AS t (
    identifier,
    integration_name,
    request_type,
    group_id,
    created_at,
    updated_at,
    record_status
)
WHERE NOT EXISTS (
    SELECT 1
    FROM integration_functionality f
    WHERE f.identifier = t.identifier
);


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
    'integration_functionality' AS name,
    'integration_functionality' AS singular_label,
    'integration_functionalities' AS plural_label,
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
    'integration_functionality' AS table_name,
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
    WHERE table_name = 'integration_functionality'
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
    WHERE table_name = 'integration_functionality'
),
field_data AS (
    SELECT * FROM (
        VALUES
            ('id', 'serial', 'bigint', NULL::INTEGER, 'USER', NULL::NUMERIC, NULL::NUMERIC, 'long', NULL::varchar[]),
            ('record_status', 'single line', 'varchar', 1000::INTEGER, 'USER', NULL::NUMERIC, NULL::NUMERIC, 'varchar', NULL::varchar[]),
            ('identifier', 'single line', 'varchar', 255::INTEGER, 'USER', NULL::NUMERIC, NULL::NUMERIC, 'varchar', NULL::varchar[]),
            ('integration_name', 'single line', 'varchar', 255::INTEGER, 'USER', NULL::NUMERIC, NULL::NUMERIC, 'varchar', NULL::varchar[]),
            ('request_type', 'drop down', 'varchar', 100::INTEGER, 'USER', NULL::NUMERIC, NULL::NUMERIC, 'varchar', '{"INBOUND","OUTBOUND"}'),
            ('group_id', 'single line', 'varchar', 255::INTEGER, 'USER', NULL::NUMERIC, NULL::NUMERIC, 'varchar', NULL::varchar[]),
            ('created_at', 'date-time', 'timestamp', NULL::INTEGER, 'USER', NULL::NUMERIC, NULL::NUMERIC, 'timestamp', NULL::varchar[]),
            ('updated_at', 'date-time', 'timestamp', NULL::INTEGER, 'USER', NULL::NUMERIC, NULL::NUMERIC, 'timestamp', NULL::varchar[])
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