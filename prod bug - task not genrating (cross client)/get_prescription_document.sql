SELECT c.case_key, copd.prescription_attachment_id
FROM "fpa-4252".c_order_prescription_details copd
join "fpa-4252".c_cases c
on copd.case_id = c.id
WHERE c.case_key in ('ODR-5689787')
AND copd.preferred_prescription IS TRUE; 