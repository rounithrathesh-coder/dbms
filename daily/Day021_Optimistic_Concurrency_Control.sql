-- ============================================================================
-- Daily DBMS Challenge - Day 021 (2026-11-13)
-- Topic: Concurrency - Optimistic Concurrency Control (OCC) with Version Vectors
-- Category: Transactions & High-Throughput Concurrency
-- RDBMS Compatibility: PostgreSQL, SQLite, MySQL 8.0+, Oracle
-- ============================================================================

-- In read-heavy distributed applications, Pessimistic Locking (SELECT ... FOR UPDATE)
-- causes lock contention, deadlocks, and severe throughput bottlenecks.
--
-- OPTIMISTIC CONCURRENCY CONTROL (OCC) assumes conflicts are rare:
-- 1. Transactions read records without acquiring locks.
-- 2. Every record maintains a monotonic `version` counter.
-- 3. On update, the transaction verifies the version has not shifted:
--      UPDATE accounts 
--      SET balance = balance - 50, version = version + 1
--      WHERE account_id = 101 AND version = :read_version;
-- 4. If rowcount == 0, another client mutated the record; client aborts & retries.

.headers on
.mode box

-- ----------------------------------------------------------------------------
-- 1. BASE SCHEMA WITH VERSION VECTOR / OCC MONOTONIC COUNTER
-- ----------------------------------------------------------------------------
DROP TABLE IF EXISTS banking_accounts;

CREATE TABLE banking_accounts (
    account_id INT PRIMARY KEY,
    account_holder VARCHAR(100) NOT NULL,
    balance NUMERIC(12, 2) NOT NULL CHECK (balance >= 0.00),
    version INT NOT NULL DEFAULT 1,
    last_updated TIMESTAMP NOT NULL
);

-- Seed Account (Initial version = 1, Balance = $1,000.00)
INSERT INTO banking_accounts VALUES 
(101, 'Devon Reed', 1000.00, 1, '2026-11-13 09:00:00');

-- ----------------------------------------------------------------------------
-- 2. SIMULATION: CONCURRENT READ PHASE (CLIENT A & CLIENT B)
-- ----------------------------------------------------------------------------
-- Client A reads account 101 (sees balance $1,000.00, version = 1)
-- Client B reads account 101 simultaneously (sees balance $1,000.00, version = 1)
SELECT 
    'CONCURRENT_READ' AS simulation_step,
    account_id,
    account_holder,
    balance,
    version
FROM banking_accounts 
WHERE account_id = 101;

-- ----------------------------------------------------------------------------
-- 3. CLIENT A COMMITS FIRST (DEPOSIT $250.00)
-- ----------------------------------------------------------------------------
-- Client A checks: WHERE account_id = 101 AND version = 1
UPDATE banking_accounts
SET balance = balance + 250.00,
    version = version + 1,
    last_updated = '2026-11-13 09:00:02'
WHERE account_id = 101 AND version = 1;

-- Verify state after Client A succeeds (Version is now 2)
SELECT 
    'POST_CLIENT_A_COMMIT' AS simulation_step,
    account_id,
    balance,
    version,
    last_updated
FROM banking_accounts
WHERE account_id = 101;

-- ----------------------------------------------------------------------------
-- 4. CLIENT B ATTEMPTS COMMIT WITH STALE VERSION (WITHDRAW $100.00)
-- ----------------------------------------------------------------------------
-- Client B still holds version = 1 in memory.
-- Executing this statement matches 0 rows! (No mutation, preventing Lost Update)
UPDATE banking_accounts
SET balance = balance - 100.00,
    version = version + 1,
    last_updated = '2026-11-13 09:00:03'
WHERE account_id = 101 AND version = 1;

-- Check changes() to detect conflict in application layer:
SELECT 
    CASE 
        WHEN changes() = 0 THEN 'OCC_CONFLICT_DETECTED: Stale version. Abort and trigger retry loop.'
        ELSE 'OCC_UPDATE_SUCCEEDED'
    END AS client_b_outcome;

-- ----------------------------------------------------------------------------
-- 5. CLIENT B RETRY LOOP: RE-READS FRESH STATE AND RE-APPLIES
-- ----------------------------------------------------------------------------
-- Client B re-reads fresh state: sees balance $1,250.00 and version = 2
-- Client B now successfully executes conditional update on version = 2
UPDATE banking_accounts
SET balance = balance - 100.00,
    version = version + 1,
    last_updated = '2026-11-13 09:00:04'
WHERE account_id = 101 AND version = 2;

-- ----------------------------------------------------------------------------
-- 6. FINAL RECONCILED STATE
-- ----------------------------------------------------------------------------
-- Both transactions were applied without dirty reads or lost updates:
-- Expected Final Balance: $1,000 + $250 - $100 = $1,150.00, version = 3
SELECT 
    'FINAL_RECONCILED_AUDIT' AS audit_step,
    account_id,
    account_holder,
    balance AS final_balance,
    version AS final_version,
    last_updated
FROM banking_accounts
WHERE account_id = 101;
