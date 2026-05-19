-- This function links a triage document to a case and updates relevant tasks with the document information.
--2003743 as reference

CREATE OR REPLACE FUNCTION "fpa-4252".link_triage_document(
    p_case_id BIGINT,
    p_document_id BIGINT,
    user_id BIGINT
)
RETURNS JSON
LANGUAGE plpgsql
AS $$
DECLARE
    v_name TEXT := 'Triage Form';
    api_response_task_id BIGINT;
    notes_task_id BIGINT;
    generate_form_task_id BIGINT;
    v_exists BOOLEAN;
BEGIN

    --------------------------------------------------
    -- Check if record exists in case documents
    --------------------------------------------------
    SELECT EXISTS (
        SELECT 1
        FROM "fpa-4252".c_case_documents
        WHERE case_id = p_case_id
          AND name = v_name
    )
    INTO v_exists;

    --------------------------------------------------
    -- Fetch task IDs
    --------------------------------------------------
    SELECT id INTO api_response_task_id
    FROM "fpa-4252".d_task
    WHERE case_id = p_case_id
      AND step_id = 'captureApiResponse'
    LIMIT 1;

    SELECT id INTO notes_task_id
    FROM "fpa-4252".d_task
    WHERE case_id = p_case_id
      AND step_id = 'confirmOrderDetailsTask'
    LIMIT 1;

    SELECT id INTO generate_form_task_id
    FROM "fpa-4252".d_task
    WHERE case_id = p_case_id
      AND step_id = 'generateTriageFormTask'
    LIMIT 1;

    --------------------------------------------------
    -- Insert or update case document
    --------------------------------------------------
    IF v_exists THEN
        UPDATE "fpa-4252".c_case_documents
        SET document_id = p_document_id
        WHERE case_id = p_case_id
          AND name = v_name;
    ELSE
        INSERT INTO "fpa-4252".c_case_documents (case_id, document_id, name)
        VALUES (p_case_id, p_document_id, v_name);
    END IF;

    --------------------------------------------------
    -- Update identifier JSON for captureApiResponse
    --------------------------------------------------
    IF api_response_task_id IS NOT NULL THEN
        UPDATE "fpa-4252".d_task
        SET identifier =
            jsonb_set(
                jsonb_set(
                    COALESCE(identifier::jsonb, '{}'::jsonb),
                    '{document_id}',
                    to_jsonb(p_document_id::text),
                    true
                ),
                '{task_id}',
                to_jsonb(notes_task_id::text),
                true
            )
        WHERE id = api_response_task_id;
    END IF;

    --------------------------------------------------
    -- Update resource_id for generateTriageForm task
    --------------------------------------------------
    IF generate_form_task_id IS NOT NULL THEN
        UPDATE "fpa-4252".d_task
        SET resource_id = p_document_id
        WHERE id = generate_form_task_id;
    END IF;

    --------------------------------------------------
    -- Return success response JSON
    --------------------------------------------------
    RETURN json_build_object(
        'status', 'SUCCESS',
        'case_id', p_case_id,
        'document_id', p_document_id,
        'message', 'Triage document linked successfully'
    );

EXCEPTION
    WHEN OTHERS THEN
        RETURN json_build_object(
            'status', 'ERROR',
            'case_id', p_case_id,
            'message', SQLERRM
        );
END;
$$;