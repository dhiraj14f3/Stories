-- This function generates a PAP alias for a given case key by fetching relevant information from the database and constructing the alias in a specific format.

CREATE OR REPLACE FUNCTION "fpa-4252".generate_pap_alias(p_case_key TEXT)
RETURNS TEXT
LANGUAGE plpgsql
AS $$
DECLARE
    v_case_id BIGINT;
    v_product_id BIGINT;
    v_trademark TEXT;
    v_product_uuid TEXT;
    v_alias TEXT;
BEGIN

    -- Step 1: fetch case_id and product_id
    SELECT id, product_id
    INTO v_case_id, v_product_id
    FROM "fpa-4252".c_cases
    WHERE case_key = p_case_key;

    IF v_case_id IS NULL THEN
        RETURN NULL;
    END IF;

    -- Step 2: fetch product info
    SELECT trademarked_name, product_uuid
    INTO v_trademark, v_product_uuid
    FROM "fpa-4252".products
    WHERE id = v_product_id;

    -- Step 3: build alias
    v_alias := 'PAP_' 
               || COALESCE(v_trademark, '') 
               || '_' 
               || COALESCE(v_product_uuid::TEXT, '') 
               || '_' 
               || p_case_key;

    RETURN json_build_object(
        'case_id', v_case_id,
        'alias', v_alias
    );

END;
$$;