-- View: fpa-1003.v_patient_enrollment_shipment_details

-- DROP VIEW "fpa-1003".v_patient_enrollment_shipment_details;

CREATE OR REPLACE VIEW "fpa-1003".v_patient_enrollment_shipment_details
 AS
 SELECT c.id,
    p.id AS patient_id,
    c.id AS case_id,
    p.id AS record_id,
    concat(u.first_name, ' ', u.last_name) AS assigned_to,
    'case_order_details'::text AS entity_type,
    c.case_key,
    c.case_key AS order_case_key,
    p.first_name AS patient_first_name,
    p.last_name AS patient_last_name,
    p.email,
    p.mobile_phone,
    ped.id AS enrollment_id,
    ped.enrollment_key,
    ped.created_by,
    ped.description,
    ped.record_status,
    ped.modified_at,
    ped.created_at,
    ped.name,
    ped.modified_by,
    ped.enrollment_start_date,
    ped.enrollment_end_date,
    ped.decision_date AS enrollment_decision_date,
    peas.decision_date,
    pet.name AS enrollment_type,
    pest.name AS enrollment_sub_type,
    es.name AS enrollment_status,
    cv.value AS withdrawl_reason,
    pede.name AS decision,
    pedr.name AS decision_reason,
    cpd.appeal_reason,
    cod.id AS order_id,
    cod.cases_id AS order_case_id,
    cod.fulfillment_type_id,
    cod.fill_type_id,
    cod.distributor_name,
    cod.queue_date,
    cs.name AS order_case_status,
    cod.record_status AS order_record_status,
    cpd.denial_reason,
    cpd.exception_reason,
    pro.trademarked_name AS product_name
   FROM "fpa-1003".c_patients p
     LEFT JOIN "fpa-1003".c_pap_enrollment_details ped ON ped.patient_id = p.id
     LEFT JOIN "fpa-1003".c_cases c ON ped.case_id = c.parent_case_id
     LEFT JOIN "fpa-1003".c_case_pap_details cpd ON cpd.cases_id = ped.case_id
     LEFT JOIN "fpa-1003".products pro ON pro.id = c.product_id
     LEFT JOIN "fpa-1003".users u ON u.id = c.user_id
     LEFT JOIN "fpa-1003".c_case_order_details cod ON cod.cases_id = c.id
     LEFT JOIN "fpa-1003".case_statuses cs ON cs.id = c.case_status_id
     LEFT JOIN "fpa-1003".c_pap_enrollment_statuses es ON es.id = ped.enrollment_status_id
     LEFT JOIN "fpa-1003".c_pap_enrollment_types pet ON pet.id = ped.pap_enrollment_type_id
     LEFT JOIN "fpa-1003".c_pap_enrollment_sub_types pest ON pest.id = ped.pap_enrollment_sub_type_id
     LEFT JOIN "fpa-1003".c_pap_enrollment_decisions pede ON pede.id = ped.decision_id
     LEFT JOIN "fpa-1003".c_pap_enrollment_decision_reasons pedr ON pedr.id = ped.decision_reason_id
     LEFT JOIN "fpa-1003".category_values cv ON cv.id = ped.withdrawal_reason_id
     LEFT JOIN "fpa-1003".c_pap_eligibility_assessments peas ON peas.id = ped.eligibility_assessment_id
  WHERE c.service_id = 65 AND c.sub_service_id = 55;







 


