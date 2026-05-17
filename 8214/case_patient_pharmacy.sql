ALTER TABLE c_cases
ADD COLUMN patient_pharmacy_id BIGINT;

INSERT INTO d_entity_fields (
    name, field_name, required, is_unique, label, type, options, default_value,
    description, field_constraints, d_entity_id, active, created_at, created_by,
    modified_at, modified_by, deleted, ui_data_type, db_data_type, foreign_key,
    not_storable, is_link_stub, control_type, control_values, auditable, char_limit,
    relation_id, min_value, max_value, tooltip_text, source_type, pattern, source_id, record_status
)
WITH entity AS (
    SELECT id, source_type
    FROM d_entities
    WHERE table_name = 'c_cases'
),
     field_data AS (
         SELECT * FROM (
                           VALUES
                               ('patient_pharmacy_id', 'number', 'bigint', 1000::INTEGER, 'USER', NULL::NUMERIC, NULL::NUMERIC)
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
    NULL,
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
    FROM d_entity_fields df
    WHERE df.d_entity_id = e.id
      AND df.field_name = field_data.field_name
);


UPDATE c_cases cc
SET
    patient_pharmacy_id = cpp.pharmacy_id,
    modified_at = CURRENT_TIMESTAMP
FROM (
    SELECT DISTINCT ON (patient_id, distributor)
           patient_id,
           distributor,
           pharmacy_id
    FROM c_patient_pharmacy
    WHERE status = 'ACTIVE'
    ORDER BY patient_id, distributor, id DESC
) cpp,
case_statuses cs
WHERE cs.id = cc.case_status_id
  AND cc.patient_id = cpp.patient_id
  AND cc.service_id = 65
  AND cs.name <> 'Pending Shipment'
  AND cs.overall_case_status = 'Open';