-- =====================================================
-- HELPER FUNCTION TO SYNC c_cases.pharmacy_id
-- =====================================================

CREATE OR REPLACE FUNCTION "fpa-1003".fn_sync_case_pharmacy(
    p_patient_id BIGINT,
    p_distributor VARCHAR
)
RETURNS VOID
LANGUAGE plpgsql
AS $BODY$
DECLARE
    v_active_pharmacy_id BIGINT;
BEGIN

    -- Fetch latest ACTIVE pharmacy
    SELECT pharmacy_id
    INTO v_active_pharmacy_id
    FROM c_patient_pharmacy
    WHERE patient_id = p_patient_id
      AND distributor = p_distributor
      AND status = 'ACTIVE'
    ORDER BY id DESC
    LIMIT 1;

    -- Update eligible cases only
    UPDATE c_cases cc
    SET
        pharmacy_id = v_active_pharmacy_id,
        modified_at = CURRENT_TIMESTAMP
    FROM case_statuses cs
    WHERE cc.case_status_id = cs.id
      AND cc.patient_id = p_patient_id
      AND cc.service_id = 65
      AND cs.name <> 'Pending Shipment'
      AND cs.overall_case_status = 'Open';

END;
$BODY$;



-- =====================================================
-- FUNCTION TO MANAGE ACTIVE / INACTIVE PHARMACIES
-- =====================================================

CREATE OR REPLACE FUNCTION "fpa-1003".fn_manage_patient_pharmacy_status()
RETURNS trigger
LANGUAGE plpgsql
AS $BODY$
BEGIN

    -- Only process when NEW status is ACTIVE
    IF UPPER(COALESCE(NEW.status, '')) = 'ACTIVE' THEN

        -- Make all other pharmacies INACTIVE
        UPDATE c_patient_pharmacy
        SET
            status = 'INACTIVE',
            modified_at = CURRENT_TIMESTAMP
        WHERE patient_id = NEW.patient_id
          AND distributor = NEW.distributor
          AND id <> NEW.id
          AND status = 'ACTIVE';

    END IF;

    -- Sync pharmacy_id in c_cases
    PERFORM "fpa-1003".fn_sync_case_pharmacy(
        NEW.patient_id,
        NEW.distributor
    );

    RETURN NEW;

END;
$BODY$;



-- =====================================================
-- DELETE HANDLER FUNCTION
-- =====================================================

CREATE OR REPLACE FUNCTION "fpa-1003".fn_sync_case_pharmacy_on_delete()
RETURNS trigger
LANGUAGE plpgsql
AS $BODY$
BEGIN

    -- Sync pharmacy_id after delete
    PERFORM "fpa-1003".fn_sync_case_pharmacy(
        OLD.patient_id,
        OLD.distributor
    );

    RETURN OLD;

END;
$BODY$;




-- =====================================================
-- INSERT / UPDATE TRIGGER
-- =====================================================

CREATE TRIGGER trg_manage_patient_pharmacy_status
AFTER INSERT OR UPDATE
ON c_patient_pharmacy
FOR EACH ROW
EXECUTE FUNCTION "fpa-1003".fn_manage_patient_pharmacy_status();



-- =====================================================
-- DELETE TRIGGER
-- =====================================================

CREATE TRIGGER trg_sync_case_pharmacy_delete
AFTER DELETE
ON c_patient_pharmacy
FOR EACH ROW
EXECUTE FUNCTION "fpa-1003".fn_sync_case_pharmacy_on_delete();