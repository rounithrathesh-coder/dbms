-- ============================================================================
-- Daily DBMS Challenge - Day 024 (2026-11-15)
-- Topic: Storage Engines - Log-Structured Merge-Trees (LSM) & Write-Ahead Logging (WAL)
-- Category: Storage Engines & Fast Append-Only Writes
-- RDBMS Compatibility: PostgreSQL, SQLite, MySQL 8.0+, RocksDB/Cassandra Principles
-- ============================================================================

-- B-Trees suffer from random write amplification because every update overwrites
-- arbitrary 8KB/16KB disk pages in-place.
-- In write-heavy workloads (e.g. timeseries, clickstreams, distributed databases),
-- LSM-TREES (Log-Structured Merge-Trees) and WRITE-AHEAD LOGS (WAL) provide superior throughput:
-- 1. Writes are sequentially appended to a Write-Ahead Log (WAL) for crash recovery.
-- 2. Writes update an in-memory sorted structure (MemTable).
-- 3. MemTable flushes to immutable disk files (SSTables - Sorted String Tables).
-- 4. Background Compaction merges SSTables, removing deleted/overwritten tombstones.

.headers on
.mode box

-- ----------------------------------------------------------------------------
-- 1. SEQUENTIAL WRITE-AHEAD LOG (WAL) & IMMUTABLE SSTABLE SIMULATION
-- ----------------------------------------------------------------------------
DROP TABLE IF EXISTS sstable_level_1;
DROP TABLE IF EXISTS write_ahead_log;

CREATE TABLE write_ahead_log (
    lsn INTEGER PRIMARY KEY AUTOINCREMENT,   -- Log Sequence Number
    record_key VARCHAR(50) NOT NULL,
    record_val TEXT NOT NULL,
    op_type VARCHAR(10) NOT NULL,            -- 'INSERT', 'UPDATE', 'DELETE' (Tombstone)
    tx_id INT NOT NULL,
    logged_at TIMESTAMP NOT NULL
);

-- Seed append-only Write-Ahead Log events (demonstrating sequential writes)
INSERT INTO write_ahead_log (record_key, record_val, op_type, tx_id, logged_at) VALUES
('session:usr_101', '{"ip": "192.168.1.1", "auth": true}', 'INSERT', 1001, '2026-11-15 10:00:01'),
('session:usr_102', '{"ip": "10.0.0.45", "auth": true}',   'INSERT', 1002, '2026-11-15 10:00:03'),
('session:usr_101', '{"ip": "192.168.1.1", "auth": false}', 'UPDATE', 1003, '2026-11-15 10:01:15'),
('session:usr_103', '{"ip": "172.16.2.8", "auth": true}',   'INSERT', 1004, '2026-11-15 10:02:20'),
('session:usr_102', '',                                      'DELETE', 1005, '2026-11-15 10:03:00'); -- Tombstone

-- ----------------------------------------------------------------------------
-- 2. QUERY 1: RECONSTRUCT CURRENT STATE VIA LATEST LOG SEQUENCE NUMBER (LSN)
-- ----------------------------------------------------------------------------
-- In LSM engines, point reads query the MemTable first, then newest to oldest SSTable.
-- If the latest log record is a tombstone (DELETE), the key does not exist.
WITH RankedLogEntries AS (
    SELECT 
        record_key,
        record_val,
        op_type,
        lsn,
        logged_at,
        ROW_NUMBER() OVER (PARTITION BY record_key ORDER BY lsn DESC) AS recency_rank
    FROM write_ahead_log
)
SELECT 
    record_key,
    record_val AS current_value,
    op_type AS last_operation,
    lsn AS latest_lsn,
    logged_at AS last_modified
FROM RankedLogEntries
WHERE recency_rank = 1 
  AND op_type != 'DELETE' -- Filter out deleted keys (tombstones)
ORDER BY record_key;

-- ----------------------------------------------------------------------------
-- 3. SIMULATING BACKGROUND COMPACTION (FLUSH & MERGE TO SSTABLE)
-- ----------------------------------------------------------------------------
-- Compaction combines multiple log segments into an immutable sorted table,
-- discarding overwritten versions and tombstones to reclaim space.
CREATE TABLE sstable_level_1 (
    record_key VARCHAR(50) PRIMARY KEY,
    record_val TEXT NOT NULL,
    compacted_at TIMESTAMP NOT NULL
);

INSERT INTO sstable_level_1 (record_key, record_val, compacted_at)
WITH CompactedState AS (
    SELECT 
        record_key,
        record_val,
        op_type,
        ROW_NUMBER() OVER (PARTITION BY record_key ORDER BY lsn DESC) AS rnk
    FROM write_ahead_log
)
SELECT 
    record_key, 
    record_val, 
    '2026-11-15 10:05:00'
FROM CompactedState
WHERE rnk = 1 AND op_type != 'DELETE';

-- ----------------------------------------------------------------------------
-- 4. QUERY 2: VERIFY COMPACTED SSTABLE
-- ----------------------------------------------------------------------------
SELECT 
    record_key,
    record_val,
    compacted_at
FROM sstable_level_1
ORDER BY record_key;
