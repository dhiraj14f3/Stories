CREATE TABLE c_patient_pharmacy (
    id BIGSERIAL PRIMARY KEY,

    patient_id BIGINT NOT NULL,

    pharmacy_id BIGINT NOT NULL,
    distributor VARCHAR(100) NOT NULL,
    distributor_id BIGINT,

    status VARCHAR(20) DEFAULT 'ACTIVE',

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by VARCHAR(100),
    record_status VARCHAR(20) DEFAULT 'ACTIVE',
    is_epr_retry_success BOOLEAN DEFAULT FALSE,

    modified_at TIMESTAMP,
    modified_by VARCHAR(100),

    UNIQUE (patient_id, pharmacy_id, distributor),

    FOREIGN KEY (patient_id) REFERENCES c_patients(id)
);