-- ============================================================================
-- REC R2023 IT Curriculum - Unit IV: Transactions, Concurrency & Recovery
-- Topic: Conflict Serializability, Multiple Granularity Locking & ARIES Recovery
-- RDBMS Compatibility: PostgreSQL, SQLite, MySQL 8.0+, Oracle
-- ============================================================================

-- 1. Conflict Serializability:
-- A schedule is conflict serializable iff its Precedence Graph (Serialization Graph) contains NO CYCLES.
-- An edge Ti -> Tj exists if Ti reads/writes an item X before Tj writes X, or Ti writes X before Tj reads/writes X.
--
-- 2. Multiple Granularity Locking (MGL):
-- Allows locking at coarse grains (Database, Table) or fine grains (Row/Record).
-- Uses Intention Locks to prevent table scans from acquiring table-level locks while sub-rows are modified:
-- - IS (Intention Shared): Intends to read sub-items.
-- - IX (Intention Exclusive): Intends to write sub-items.
-- - SIX (Shared + Intention Exclusive): Reads whole table, modifies sub-items.
--
-- 3. ARIES Recovery Algorithm (Algorithms for Recovery and Isolation Exploiting Semantics):
-- - Analysis Phase: Scan WAL forward from last checkpoint to find dirty pages and active transactions (Losers).
-- - Redo Phase: Replays all logged changes (repeating history) to restore pre-crash state.
-- - Undo Phase: Scans WAL backward, rolling back active Loser transactions and writing Compensation Log Records (CLRs).

.headers on
.mode box

-- ----------------------------------------------------------------------------
-- 1. PRECEDENCE GRAPH / CONFLICT SERIALIZABILITY CYCLE DETECTOR
-- ----------------------------------------------------------------------------
DROP TABLE IF EXISTS precedence_graph_edges;

CREATE TABLE precedence_graph_edges (
    source_tx VARCHAR(10) NOT NULL,
    target_tx VARCHAR(10) NOT NULL,
    conflicting_item VARCHAR(20) NOT NULL,
    PRIMARY KEY (source_tx, target_tx, conflicting_item)
);

-- Seed Schedule S1 edges: T1 -> T2 on Account X, T2 -> T3 on Account Y
INSERT INTO precedence_graph_edges VALUES
('T1', 'T2', 'ACC_X'),
('T2', 'T3', 'ACC_Y');

-- Introduce a cyclic back-edge T3 -> T1 to simulate non-serializable conflict:
-- ('T3', 'T1', 'ACC_Z'); -- UNCOMMENTING THIS CREATES A CYCLE!

-- Cycle Detection Query using Recursive CTE:
WITH RECURSIVE CycleDetector AS (
    SELECT 
        source_tx,
        target_tx,
        source_tx || ' -> ' || target_tx AS path,
        0 AS is_cycle
    FROM precedence_graph_edges

    UNION ALL

    SELECT 
        c.source_tx,
        e.target_tx,
        c.path || ' -> ' || e.target_tx,
        CASE WHEN c.source_tx = e.target_tx THEN 1 ELSE 0 END
    FROM CycleDetector c
    JOIN precedence_graph_edges e ON c.target_tx = e.source_tx
    WHERE c.is_cycle = 0 AND LENGTH(c.path) < 50
)
SELECT 
    source_tx,
    target_tx,
    path,
    CASE WHEN is_cycle = 1 THEN 'CYCLE_DETECTED: NOT SERIALIZABLE' ELSE 'SERIALIZABLE_PATH' END AS conflict_status
FROM CycleDetector;

-- ----------------------------------------------------------------------------
-- 2. MULTIPLE GRANULARITY LOCKING (MGL) COMPATIBILITY MATRIX
-- ----------------------------------------------------------------------------
DROP TABLE IF EXISTS mgl_compatibility_matrix;

CREATE TABLE mgl_compatibility_matrix (
    requested_lock VARCHAR(5) PRIMARY KEY,
    is_compat VARCHAR(30),
    ix_compat VARCHAR(30),
    s_compat VARCHAR(30),
    six_compat VARCHAR(30),
    x_compat VARCHAR(30)
);

INSERT INTO mgl_compatibility_matrix VALUES
('IS',  'YES', 'YES', 'YES', 'YES', 'NO'),
('IX',  'YES', 'YES', 'NO',  'NO',  'NO'),
('S',   'YES', 'NO',  'YES', 'NO',  'NO'),
('SIX', 'YES', 'NO',  'NO',  'NO',  'NO'),
('X',   'NO',  'NO',  'NO',  'NO',  'NO');

SELECT 
    requested_lock AS "Request \ Held",
    is_compat AS "IS",
    ix_compat AS "IX",
    s_compat AS "S",
    six_compat AS "SIX",
    x_compat AS "X"
FROM mgl_compatibility_matrix;

-- ----------------------------------------------------------------------------
-- 3. ARIES RECOVERY LOG SIMULATION
-- ----------------------------------------------------------------------------
DROP TABLE IF EXISTS aries_wal_log;

CREATE TABLE aries_wal_log (
    lsn INT PRIMARY KEY,
    prev_lsn INT,
    tx_id VARCHAR(10),
    type VARCHAR(20),      -- 'UPDATE', 'COMMIT', 'CLR' (Compensation Log Record)
    page_id VARCHAR(20),
    undo_next_lsn INT NULL
);

-- Seed log demonstrating crash recovery
INSERT INTO aries_wal_log VALUES
(101, NULL, 'T1', 'UPDATE', 'PAGE_A', NULL),
(102, NULL, 'T2', 'UPDATE', 'PAGE_B', NULL),
(103, 101,  'T1', 'COMMIT', NULL,     NULL), -- T1 committed
(104, 102,  'T2', 'UPDATE', 'PAGE_C', NULL); -- Crash occurs! T2 is an active "Loser" transaction!

-- Analysis Phase: Determine Loser transactions requiring UNDO
SELECT 
    tx_id AS loser_transaction_to_undo,
    MAX(lsn) AS last_lsn_to_rollback
FROM aries_wal_log
WHERE tx_id NOT IN (SELECT tx_id FROM aries_wal_log WHERE type = 'COMMIT')
GROUP BY tx_id;
