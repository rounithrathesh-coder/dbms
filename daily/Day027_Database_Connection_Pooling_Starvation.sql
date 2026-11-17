-- ============================================================================
-- Daily DBMS Challenge - Day 027 (2026-11-17)
-- Topic: Database Reliability - Connection Pooling Starvation & Leaked Connection Reaping
-- Category: High-Availability Infrastructure & Connection Management
-- RDBMS Compatibility: PostgreSQL (pg_stat_activity), MySQL (processlist), SQLite, HikariCP
-- ============================================================================

-- Opening a physical database socket connection involves TCP handshakes, TLS negotiation,
-- authentication, and memory allocation (~10ms–100ms per connection).
--
-- Connection Pools (HikariCP, PgBouncer) maintain pre-warmed connections to service requests in microseconds.
--
-- Severe Failure Mode - Connection Starvation:
-- If application threads fail to return connections (missing try-with-resources or hung queries),
-- the pool is exhausted. Incoming queries queue up until they hit `connectionTimeout` (e.g. 30s),
-- crashing upstream web servers in a cascading failure.
--
-- Solution: Active Connection Auditing, Lease Timeouts & Automated Reaper Workers.

.headers on
.mode box

-- ----------------------------------------------------------------------------
-- 1. CONNECTION POOL REGISTRY & QUERY WORKER SIMULATION
-- ----------------------------------------------------------------------------
DROP TABLE IF EXISTS connection_pool_slots;

CREATE TABLE connection_pool_slots (
    slot_id INT PRIMARY KEY,
    status VARCHAR(20) NOT NULL,          -- 'IDLE', 'IN_USE', 'TERMINATED'
    assigned_thread VARCHAR(50) NULL,
    current_query VARCHAR(100) NULL,
    leased_at TIMESTAMP NULL,
    max_lease_seconds INT NOT NULL DEFAULT 30
);

-- Seed a 5-connection pool (Simulating HikariCP max-pool-size = 5)
-- Two normal fast queries, one idle slot, and TWO LEAKED/HUNG queries!
INSERT INTO connection_pool_slots VALUES
(1, 'IN_USE', 'Worker-Thread-1', 'SELECT * FROM users WHERE id = 42', '2026-11-17 12:00:00', 30),
(2, 'IDLE',   NULL,              NULL,                               NULL,                 30),
(3, 'IN_USE', 'Worker-Thread-3', 'UPDATE inventory SET qty = qty - 1', '2026-11-17 12:00:02', 30),
-- Slot 4 & 5: Leaked connections! Thread hung or forgotten close() for over 180 seconds!
(4, 'IN_USE', 'Analytics-Worker-4', 'SELECT * FROM event_logs ORDER BY id', '2026-11-17 11:57:00', 30),
(5, 'IN_USE', 'Report-Worker-5',    'SELECT * FROM transactions',          '2026-11-17 11:56:30', 30);

-- ----------------------------------------------------------------------------
-- 2. QUERY 1: POOL SATURATION & UTILIZATION DASHBOARD (AS OF 12:00:05)
-- ----------------------------------------------------------------------------
-- Current timestamp: '2026-11-17 12:00:05'
SELECT 
    COUNT(*) AS total_pool_capacity,
    SUM(CASE WHEN status = 'IN_USE' THEN 1 ELSE 0 END) AS active_connections,
    SUM(CASE WHEN status = 'IDLE' THEN 1 ELSE 0 END) AS idle_connections,
    ROUND(SUM(CASE WHEN status = 'IN_USE' THEN 1.0 ELSE 0.0 END) / COUNT(*) * 100, 1) || '%' AS pool_saturation
FROM connection_pool_slots;

-- ----------------------------------------------------------------------------
-- 3. QUERY 2: LEAKED CONNECTION DETECTION QUERY
-- ----------------------------------------------------------------------------
-- Find connections exceeding max lease duration (elapsed seconds > 30s)
WITH LeakedAuditing AS (
    SELECT 
        slot_id,
        assigned_thread,
        current_query,
        leased_at,
        max_lease_seconds,
        -- Calculate lease duration in seconds as of 12:00:05
        CAST((strftime('%s', '2026-11-17 12:00:05') - strftime('%s', leased_at)) AS INT) AS elapsed_seconds
    FROM connection_pool_slots
    WHERE status = 'IN_USE'
)
SELECT 
    slot_id,
    assigned_thread,
    current_query,
    elapsed_seconds || 's' AS lease_duration,
    max_lease_seconds || 's' AS timeout_limit,
    CASE 
        WHEN elapsed_seconds > max_lease_seconds THEN 'LEAK_DETECTED: FORCE_REAP'
        ELSE 'HEALTHY_ACTIVE'
    END AS connection_health
FROM LeakedAuditing
ORDER BY elapsed_seconds DESC;

-- ----------------------------------------------------------------------------
-- 4. SIMULATE AUTOMATED POOL REAPER: TERMINATE & RECLAIM HUNG SLOTS
-- ----------------------------------------------------------------------------
-- Evict connections exceeding max_lease_seconds and return slots to IDLE
UPDATE connection_pool_slots
SET status = 'IDLE',
    assigned_thread = NULL,
    current_query = NULL,
    leased_at = NULL
WHERE status = 'IN_USE' 
  AND (strftime('%s', '2026-11-17 12:00:05') - strftime('%s', leased_at)) > max_lease_seconds;

-- ----------------------------------------------------------------------------
-- 5. QUERY 3: RECONCILED POST-REAP HEALTHY POOL METRICS
-- ----------------------------------------------------------------------------
SELECT 
    slot_id,
    status,
    COALESCE(assigned_thread, 'AVAILABLE') AS current_owner,
    COALESCE(current_query, 'AWAITING_QUERY') AS query_status
FROM connection_pool_slots
ORDER BY slot_id;
