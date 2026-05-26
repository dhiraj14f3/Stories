

CREATE SEQUENCE IF NOT EXISTS generic_payload_id_seq;

-- Set sequence current value to max(id)
SELECT setval(
    'generic_payload_id_seq',
    COALESCE((SELECT MAX(id) FROM generic_payload), 1)
);

-- Make id auto-populate
ALTER TABLE generic_payload
ALTER COLUMN id
SET DEFAULT nextval('generic_payload_id_seq');


DO $$
BEGIN
    LOOP
        UPDATE generic_payload
        SET id = nextval('generic_payload_id_seq')
        WHERE ctid IN (
            SELECT ctid
            FROM generic_payload
            WHERE id IS NULL
            LIMIT 50000
        );

        EXIT WHEN NOT FOUND;
    END LOOP;
END $$;

ALTER TABLE generic_payload
ALTER COLUMN id SET NOT NULL;
