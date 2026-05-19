--2003743
CREATE OR REPLACE FUNCTION "fpa-4252".create_triage_capture_shipment_and_complete_tasks(
    p_case_key TEXT,
    p_triage_form_id BIGINT,
    user_id BIGINT
)
RETURNS JSONB
LANGUAGE plpgsql
AS
$$
DECLARE
    v_case_id                      BIGINT;
    v_assignee_id                  BIGINT := 1;
    v_requestor_id                 BIGINT;
    v_start_date                   TIMESTAMP;
    v_due_date                     TIMESTAMP;
    v_d_prc_inst_id                BIGINT;
    v_org_id                       BIGINT;
    v_performer_id                 BIGINT;
    v_group_id                     BIGINT;

    v_generate_task_id             BIGINT;
    v_capture_api_task_id          BIGINT;
    v_capture_shipment_task_id     BIGINT;
    v_complete_task_id             BIGINT;
BEGIN

--------------------------------------------------
-- 1) Get case_id
--------------------------------------------------
SELECT id
INTO v_case_id
FROM "fpa-4252".c_cases
WHERE case_key = p_case_key;

IF v_case_id IS NULL THEN
    RETURN jsonb_build_object(
        'success', false,
        'message', 'Case not found',
        'case_key', p_case_key
    );
END IF;

--------------------------------------------------
-- 2) Common data from latest task
--------------------------------------------------
SELECT 
    requestor_id,
    d_prc_inst_id,
    organization_id,
    performer_id,
    group_id
INTO 
    v_requestor_id,
    v_d_prc_inst_id,
    v_org_id,
    v_performer_id,
    v_group_id
FROM "fpa-4252".d_task
WHERE case_id = v_case_id
ORDER BY created_at DESC
LIMIT 1;

--------------------------------------------------
-- 3) Get last NON-NULL start & due date
--------------------------------------------------
SELECT start_date, due_date
INTO v_start_date, v_due_date
FROM "fpa-4252".d_task
WHERE case_id = v_case_id
  AND start_date IS NOT NULL
  AND due_date IS NOT NULL
ORDER BY created_at DESC
LIMIT 1;

--------------------------------------------------
-- 4) Override requestor from Eligibility task
--------------------------------------------------
SELECT requestor_id
INTO v_requestor_id
FROM "fpa-4252".d_task
WHERE case_id = v_case_id
  AND name = 'Eligibility Assessment for Fill'
LIMIT 1;

--------------------------------------------------
-- 5) UPDATE OLD captureShipmentRecordTask
--------------------------------------------------
UPDATE "fpa-4252".d_task
SET 
    state = 'CANCELLED',
    step_id = 'captureShipmentRecordTask_old',
    modified_at = NOW(),
    assignee_id = v_assignee_id,
    modified_by = 'SYSTEM'
WHERE case_id = v_case_id
  AND step_id = 'captureShipmentRecordTask';

--------------------------------------------------
-- 6) INSERT: Generate Triage Form
--------------------------------------------------
INSERT INTO "fpa-4252".d_task (
    step_id,
    case_id,
    name,
    state,
    assignee_id,
    requestor_id,
    resource_id,
    start_date,
    due_date,
    completion_date,
    modified_by,
    created_by,
    record_status,
    d_prc_inst_id,
    task_template_id,
    identifier,
    organization_id,
    performer_id,
    group_id
)
VALUES (
    'generateTriageFormTask',
    v_case_id,
    'Generate Triage Form',
    'COMPLETED',
    v_assignee_id,
    v_requestor_id,
    p_triage_form_id,
    v_start_date,
    v_due_date,
    NOW(),
    'SYSTEM',
    'SYSTEM',
    'ACTIVE',
    v_d_prc_inst_id,
    4,
    '{"ui_identifier":"DOCUMENT_PREVIEW_TASK"}'::jsonb,
    v_org_id,
    v_performer_id,
    v_group_id
)
RETURNING id INTO v_generate_task_id;

--------------------------------------------------
-- 7) INSERT: Capture API Response
--------------------------------------------------
INSERT INTO "fpa-4252".d_task (
    step_id,
    case_id,
    name,
    state,
    assignee_id,
    requestor_id,
    resource_id,
    start_date,
    due_date,
    completion_date,
    modified_by,
    created_by,
    record_status,
    d_prc_inst_id,
    task_template_id,
    identifier,
    organization_id,
    performer_id,
    group_id
)
VALUES (
    'captureApiResponse',
    v_case_id,
    'Capture API Response',
    'COMPLETED',
    v_assignee_id,
    v_requestor_id,
    p_triage_form_id,
    v_start_date,
    v_due_date,
    NOW(),
    'SYSTEM',
    'SYSTEM',
    'ACTIVE',
    v_d_prc_inst_id,
    4,
    jsonb_build_object(
        'eval_keys', jsonb_build_array('document_id', 'task_id'),
        'task_id', v_generate_task_id,
        'document_id', p_triage_form_id,
        'signal', 'stepIntoCdsSubprocess',
        'entity_id', '32',
        'entity_name', 'case',
        'layout_info', jsonb_build_object(
            'layout_id', '85',
            'layout_type', 'EDIT_MODE'
        ),
        'ui_identifier', 'PAP_CAPTURE_API_RESPONSE',
        'action_buttons', jsonb_build_object(
            'edit', false,
            'save', false,
            'cancel', false,
            'resend', false,
            'preview', false,
            'download', false,
            'save_draft', false
        )
    ),
    v_org_id,
    v_performer_id,
    v_group_id
)
RETURNING id INTO v_capture_api_task_id;

--------------------------------------------------
-- 8) INSERT: Capture Shipment Record
--------------------------------------------------
INSERT INTO "fpa-4252".d_task (
    step_id,
    case_id,
    name,
    state,
    assignee_id,
    requestor_id,
    start_date,
    due_date,
    completion_date,
    modified_by,
    created_by,
    record_status,
    d_prc_inst_id,
    task_template_id,
    identifier,
    organization_id,
    performer_id,
    group_id
)
VALUES (
    'captureShipmentRecordTask',
    v_case_id,
    'Capture Shipment Record',
    'COMPLETED',
    v_assignee_id,
    v_requestor_id,
    v_start_date,
    v_due_date,
    NOW(),
    'SYSTEM',
    'SYSTEM',
    'ACTIVE',
    v_d_prc_inst_id,
    4,
    '{
        "entity_id": "32",
        "validation": "true",
        "entity_name": "case",
        "layout_info": {
            "layout_id": "8793",
            "layout_type": "EDIT_MODE"
        },
        "ui_identifier": "ENTITY_LAYOUT",
        "action_buttons": {
            "edit": false,
            "save": false,
            "cancel": false,
            "resend": false,
            "preview": false,
            "download": false,
            "save_draft": false
        }
    }'::jsonb,
    v_org_id,
    v_performer_id,
    v_group_id
)
RETURNING id INTO v_capture_shipment_task_id;

--------------------------------------------------
-- 9) INSERT: Complete Case
--------------------------------------------------
INSERT INTO "fpa-4252".d_task (
    step_id,
    case_id,
    name,
    state,
    assignee_id,
    requestor_id,
    start_date,
    due_date,
    completion_date,
    modified_by,
    created_by,
    record_status,
    identifier,
    organization_id,
    performer_id,
    group_id
)
VALUES (
    'deniedCompleteCase',
    v_case_id,
    'Complete Case',
    'COMPLETED',
    v_assignee_id,
    v_requestor_id,
    v_start_date,
    v_due_date,
    NOW(),
    'SYSTEM',
    'SYSTEM',
    'ACTIVE',
    '{"ui_identifier":"NO_PREVIEW"}'::jsonb,
    v_org_id,
    v_performer_id,
    v_group_id
)
RETURNING id INTO v_complete_task_id;

--------------------------------------------------
-- 10) Update Case Status
--------------------------------------------------
UPDATE "fpa-4252".c_cases
SET 
    case_status_id = 10039,
    modified_at = NOW(),
    modified_by = 'SYSTEM'
WHERE id = v_case_id;

--------------------------------------------------
-- 11) Update Process Instance
--------------------------------------------------
UPDATE "fpa-4252".d_process_instance
SET 
    current_group = 'completeCase',
    current_group_state = 'COMPLETED',
    modified_at = NOW(),
    modified_by = 'SYSTEM'
WHERE case_id = v_case_id;

--------------------------------------------------
-- 12) Return Response
--------------------------------------------------
RETURN jsonb_build_object(
    'success', true,
    'message', 'Tasks created successfully',
    'case_id', v_case_id,
    'case_key', p_case_key,
    'generate_triage_form_task_id', v_generate_task_id,
    'capture_api_response_task_id', v_capture_api_task_id,
    'capture_shipment_record_task_id', v_capture_shipment_task_id,
    'complete_case_task_id', v_complete_task_id,
    'triage_form_id', p_triage_form_id
);

EXCEPTION
WHEN OTHERS THEN
    RETURN jsonb_build_object(
        'success', false,
        'message', SQLERRM,
        'case_key', p_case_key
    );
END;
$$;


-- Example Usage
-- SELECT "fpa-4252".create_triage_capture_shipment_and_complete_tasks(
--     'ODR-1161955',
--     1802115
-- );