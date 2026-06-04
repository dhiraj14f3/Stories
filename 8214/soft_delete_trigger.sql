-- =====================================================
-- BEFORE UPDATE FUNCTION
-- =====================================================

CREATE OR REPLACE FUNCTION fn_mark_patient_pharmacy_inactive()
RETURNS trigger
LANGUAGE plpgsql
AS $BODY$
BEGIN

    -- Patient unassigned
    IF OLD.patient_id IS NOT NULL
       AND NEW.patient_id IS NULL THEN

        NEW.record_status := 'INACTIVE';

        NEW.modified_at := CURRENT_TIMESTAMP;
    END IF;

    RETURN NEW;

END;
$BODY$;


CREATE OR REPLACE TRIGGER trg_mark_patient_pharmacy_inactive
BEFORE UPDATE
ON c_patient_pharmacy
FOR EACH ROW
EXECUTE FUNCTION fn_mark_patient_pharmacy_inactive();