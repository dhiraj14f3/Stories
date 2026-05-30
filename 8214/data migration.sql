INSERT INTO c_patient_pharmacy (
    patient_id,
    pharmacy_id,
    distributor,
    status,
    created_at,
    created_by
)
SELECT
    cp.id AS patient_id,
    cp.pharmacy_id,
    'Neovance Specialty Pharmacy' AS distributor,
    'ACTIVE',
    CURRENT_TIMESTAMP,
    'SYSTEM'
FROM c_patients cp
WHERE cp.pharmacy_id IS NOT NULL
ON CONFLICT (patient_id, pharmacy_id, distributor)
DO NOTHING;



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
  AND cs.overall_case_status = 'Open';