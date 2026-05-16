CREATE SEQUENCE IF NOT EXISTS "fpa-1003".generic_payload_id_seq;

-- Set sequence current value to max(id)
SELECT setval(
    '"fpa-1003".generic_payload_id_seq',
    COALESCE((SELECT MAX(id) FROM "fpa-1003".generic_payload), 0)
);

-- Make id auto-populate
ALTER TABLE "fpa-1003".generic_payload
ALTER COLUMN id
SET DEFAULT nextval('"fpa-1003".generic_payload_id_seq');