SELECT c.case_key as case_key, copd.prescription_attachment_id as prescription_attachment_id,
dt.id as task_id
FROM "fpa-4252".c_order_prescription_details copd
join "fpa-4252".c_cases c
join "fpa-4252".d_task dt
on copd.case_id = c.id
and dt.case_id = c.id
WHERE c.case_key in ('ODR-5689787')
AND dt.step_id = 'confirmOrderDetailsTask'
AND copd.preferred_prescription IS TRUE; 