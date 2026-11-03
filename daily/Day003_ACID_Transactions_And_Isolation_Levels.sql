-- ============================================================================
-- Daily DBMS Challenge - Day 003
-- Topic: Transactions - ACID Properties & Isolation Levels
-- ============================================================================

DROP TABLE IF EXISTS bank_accounts;

CREATE TABLE bank_accounts (
    account_id INT PRIMARY KEY,
    holder_name VARCHAR(100) NOT NULL,
    balance NUMERIC(12, 2) NOT NULL CHECK (balance >= 0)
);

INSERT INTO bank_accounts (account_id, holder_name, balance) VALUES
(1, 'Alice', 5000.00),
(2, 'Bob', 1200.00);

-- Demonstration of an Atomic Money Transfer with SAVEPOINT
BEGIN TRANSACTION;

-- Step 1: Deduct from Alice
UPDATE bank_accounts
SET balance = balance - 500.00
WHERE account_id = 1;

SAVEPOINT deduction_complete;

-- Step 2: Add to Bob
UPDATE bank_accounts
SET balance = balance + 500.00
WHERE account_id = 2;

-- If any validation fails, we could ROLLBACK TO deduction_complete;
COMMIT;

SELECT * FROM bank_accounts;
