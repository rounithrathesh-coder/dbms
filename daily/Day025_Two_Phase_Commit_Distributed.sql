-- ============================================================================
-- Daily DBMS Challenge - Day 025 (2026-11-16)
-- Topic: Distributed Systems - Two-Phase Commit (2PC) Protocol & Consensus Coordination
-- Category: Distributed Transactions & Cross-Shard ACID
-- RDBMS Compatibility: PostgreSQL, SQLite, MySQL 8.0+, Spanner/CockroachDB Principles
-- ============================================================================

-- When transactions span multiple database shards or distinct microservices,
-- local ACID guarantees are insufficient.
--
-- The TWO-PHASE COMMIT (2PC) protocol guarantees atomicity across distributed nodes:
-- 1. Phase 1 (Prepare): Coordinator asks all cohorts "Can you commit?".
--    Each cohort acquires local locks, writes undo/redo logs, and votes YES or NO.
-- 2. Phase 2 (Commit/Abort):
--    - If ALL cohorts vote YES -> Coordinator issues GLOBAL_COMMIT.
--    - If ANY cohort votes NO or times out -> Coordinator issues GLOBAL_ABORT.

.headers on
.mode box

-- ----------------------------------------------------------------------------
-- 1. DISTRIBUTED TRANSACTION COORDINATOR LOG & COHORT NODES SIMULATION
-- ----------------------------------------------------------------------------
DROP TABLE IF EXISTS cohort_wallets;
DROP TABLE IF EXISTS cohort_inventory;
DROP TABLE IF EXISTS tx_coordinator_log;

CREATE TABLE tx_coordinator_log (
    global_tx_id VARCHAR(50) PRIMARY KEY,
    state VARCHAR(20) NOT NULL,          -- 'INIT', 'PREPARING', 'COMMITTED', 'ABORTED'
    cohort_count INT NOT NULL,
    yes_votes INT NOT NULL DEFAULT 0,
    created_at TIMESTAMP NOT NULL,
    updated_at TIMESTAMP NOT NULL
);

-- Shard A: User Wallets Table
CREATE TABLE cohort_wallets (
    user_id INT PRIMARY KEY,
    balance NUMERIC(10, 2) NOT NULL CHECK (balance >= 0)
);

-- Shard B: Warehouse Inventory Table
CREATE TABLE cohort_inventory (
    sku VARCHAR(20) PRIMARY KEY,
    stock_qty INT NOT NULL CHECK (stock_qty >= 0)
);

-- Seed Initial Shard Balances
INSERT INTO cohort_wallets VALUES (101, 500.00);
INSERT INTO cohort_inventory VALUES ('SKU-LAPTOP-99', 5);

-- ----------------------------------------------------------------------------
-- 2. SIMULATION SCENARIO 1: SUCCESSFUL TWO-PHASE COMMIT (PURCHASE 1 LAPTOP FOR $300)
-- ----------------------------------------------------------------------------
-- Step 1: Coordinator initializes transaction
INSERT INTO tx_coordinator_log VALUES 
('TX-2PC-SUCCESS-001', 'PREPARING', 2, 0, '2026-11-16 11:00:00', '2026-11-16 11:00:00');

-- Step 2: Cohort A (Wallet) Prepares: Checks balance ($500 >= $300) -> Votes YES
-- Cohort B (Inventory) Prepares: Checks stock (5 >= 1) -> Votes YES
UPDATE tx_coordinator_log 
SET yes_votes = 2,
    state = 'COMMITTED',
    updated_at = '2026-11-16 11:00:02'
WHERE global_tx_id = 'TX-2PC-SUCCESS-001' AND yes_votes + 2 = cohort_count;

-- Step 3: Phase 2 Commit execution on Shards
UPDATE cohort_wallets SET balance = balance - 300.00 WHERE user_id = 101;
UPDATE cohort_inventory SET stock_qty = stock_qty - 1 WHERE sku = 'SKU-LAPTOP-99';

-- ----------------------------------------------------------------------------
-- 3. SIMULATION SCENARIO 2: ABORTED TWO-PHASE COMMIT (INSUFFICIENT FUNDS)
-- ----------------------------------------------------------------------------
-- User tries to buy 2 more laptops ($600), but remaining balance is only $200!
INSERT INTO tx_coordinator_log VALUES 
('TX-2PC-FAIL-002', 'PREPARING', 2, 0, '2026-11-16 11:05:00', '2026-11-16 11:05:00');

-- Cohort A votes NO (balance $200 < $600 required)
-- Coordinator records GLOBAL_ABORT and rolls back all cohorts
UPDATE tx_coordinator_log 
SET state = 'ABORTED',
    updated_at = '2026-11-16 11:05:01'
WHERE global_tx_id = 'TX-2PC-FAIL-002';

-- ----------------------------------------------------------------------------
-- 4. QUERY 1: COORDINATOR AUDIT LOG
-- ----------------------------------------------------------------------------
SELECT 
    global_tx_id,
    state AS final_consensus,
    cohort_count,
    yes_votes,
    updated_at AS decision_time
FROM tx_coordinator_log
ORDER BY created_at;

-- ----------------------------------------------------------------------------
-- 5. QUERY 2: COHORT RECONCILIATION STATE
-- ----------------------------------------------------------------------------
SELECT 
    w.user_id,
    w.balance AS remaining_wallet_balance,
    i.sku,
    i.stock_qty AS remaining_warehouse_stock
FROM cohort_wallets w
CROSS JOIN cohort_inventory i;
