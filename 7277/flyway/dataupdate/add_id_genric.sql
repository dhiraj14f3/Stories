UPDATE ${tenant_name}.integration_definitions id
SET group_id = ifn.group_id
FROM ${tenant_name}.integration_functionality ifn
WHERE id.integration_name = ifn.identifier
  AND id.integration_name != 'maxrte-token';


CREATE SEQUENCE IF NOT EXISTS ${tenant_name}.generic_payload_id_seq;

-- Set sequence current value to max(id)
SELECT setval(
    '${tenant_name}.generic_payload_id_seq',
    COALESCE((SELECT MAX(id) FROM ${tenant_name}.generic_payload), 1)
);

-- Make id auto-populate
ALTER TABLE ${tenant_name}.generic_payload
ALTER COLUMN id
SET DEFAULT nextval('${tenant_name}.generic_payload_id_seq');


DO $$
BEGIN
    LOOP
        UPDATE ${tenant_name}.generic_payload
        SET id = nextval('${tenant_name}.generic_payload_id_seq')
        WHERE ctid IN (
            SELECT ctid
            FROM ${tenant_name}.generic_payload
            WHERE id IS NULL
            LIMIT 50000
        );

        EXIT WHEN NOT FOUND;
    END LOOP;
END $$;


ALTER TABLE ${tenant_name}.generic_payload
ALTER COLUMN id SET NOT NULL;
