-- Topic Query Reference: 2026-06-28
-- Data Integrity and Domain Constraints
CREATE DOMAIN postal_code AS VARCHAR(10)
CHECK (VALUE ~ '^[0-9]{5}(-[0-9]{4})?$');

CREATE TABLE verified_accounts (
    account_id BIGSERIAL PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(255) NOT NULL,
    balance NUMERIC(15, 2) NOT NULL DEFAULT 0.00,
    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    CONSTRAINT chk_positive_balance CHECK (balance >= 0.00),
    CONSTRAINT chk_status_enum CHECK (status IN ('ACTIVE', 'SUSPENDED', 'CLOSED'))
);

-- Revision Note: Checked on 2026-07-15 09:11:00

-- Revision Note: Checked on 2026-09-25 08:41:48

-- Topic Evaluation Note: Checked on 2026-06-20 11:06:57

-- Topic Evaluation Note: Checked on 2026-06-24 19:42:05

-- Topic Evaluation Note: Checked on 2026-07-05 14:54:16
