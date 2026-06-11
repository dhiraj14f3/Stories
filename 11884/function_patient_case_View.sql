CREATE OR REPLACE FUNCTION "fpa-1003".get_patient_cases_view(
    p_patient_id BIGINT,
    user_id BIGINT
)
RETURNS TABLE (
    id BIGINT,
    patient_id BIGINT,
    record_id BIGINT,
    record_status TEXT,
    case_id VARCHAR,
    product_name VARCHAR,
    patient_name TEXT,
    overall_status VARCHAR,
    case_status VARCHAR,
    service_type VARCHAR,
    sub_service_type VARCHAR,
    outcome VARCHAR,
    outcome_reason VARCHAR,
    case_completion_date TIMESTAMP,
    user_name TEXT,
    provider_name TEXT,
    channel VARCHAR,
    parent_case_id BIGINT,
    created_by VARCHAR,
    created_at TIMESTAMP,
    modified_by VARCHAR,
    modified_at TIMESTAMP,
    case_document_count BIGINT,
    entity_type TEXT
)
LANGUAGE SQL
STABLE
AS
$$
WITH patient_cases AS (
    SELECT *
    FROM "fpa-1003".c_cases
    WHERE patient_id = p_patient_id
)
SELECT
    pc.id AS id,
    p.id AS patient_id,
    p.id AS record_id,
    'ACTIVE'::TEXT AS record_status,
    pc.case_key,
    pr.trademarked_name,
    CONCAT(p.first_name, ' ', p.last_name),
    sts.overall_case_status,
    sts.name,
    srv.service_name,
    ss.name,
    oc.name,
    ocr.name,
    pc.case_completion_date,
    CONCAT(u.first_name, ' ', u.last_name),
    CONCAT(cp.first_name, ' ', cp.last_name),
    ch.value,
    pc.parent_case_id,
    pc.created_by,
    pc.created_at,
    pc.modified_by,
    pc.modified_at,
    COALESCE(cd.cnt, 0)::BIGINT,
    'patient_cases_view'::TEXT AS entity_type
FROM patient_cases pc
JOIN "fpa-1003".c_patients p
    ON p.id = pc.patient_id
LEFT JOIN "fpa-1003".products pr
    ON pr.id = pc.product_id
LEFT JOIN "fpa-1003".case_statuses sts
    ON sts.id = pc.case_status_id
LEFT JOIN "fpa-1003".services srv
    ON srv.id = pc.service_id
LEFT JOIN "fpa-1003".c_sub_services ss
    ON ss.id = pc.sub_service_id
LEFT JOIN "fpa-1003".c_case_summary csm
    ON csm.cases_id = pc.id
LEFT JOIN "fpa-1003".c_outcomes oc
    ON oc.id = csm.outcome_id
LEFT JOIN "fpa-1003".c_outcome_reasons ocr
    ON ocr.id = csm.outcome_reason_id
LEFT JOIN "fpa-1003".users u
    ON u.id = pc.user_id
LEFT JOIN config.c_providers cp
    ON cp.id = pc.provider_id
LEFT JOIN "fpa-1003".category_values ch
    ON ch.id = pc.intake_channel_id
   AND ch.category = 'Intake Channel'
LEFT JOIN LATERAL (
    SELECT COUNT(*)::BIGINT AS cnt
    FROM "fpa-1003".c_case_documents d
    WHERE d.case_id = pc.id
) cd ON TRUE;
$$;


UPDATE "fpa-1003".layout_added_fields lf
SET function_parameters = jsonb_build_object(
    'params',
    jsonb_build_object(
        'id',
        jsonb_build_object(
            'type', 'LONGDATATYPE',
            'order', 1
        )
    ),
    'functionName',
    'get_patient_cases_view'
)
FROM "fpa-1003".layout l
WHERE lf.layout_id = l.id
  AND lf.field_name = 'c_patient_cases_view_patient'
  AND l.name = 'Patient Edit Layout';


UPDATE "fpa-1003".layout_added_fields lf
SET function_parameters = jsonb_build_object(
    'params',
    jsonb_build_object(
        'id',
        jsonb_build_object(
            'type', 'LONGDATATYPE',
            'order', 1
        )
    ),
    'functionName',
    'get_patient_cases_view'
)
FROM "fpa-1003".layout l
WHERE lf.layout_id = l.id
  AND lf.field_name = 'c_patient_cases_view_patient'
  AND l.name = 'Patient Default View';