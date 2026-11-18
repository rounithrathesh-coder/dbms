-- ============================================================================
-- Daily DBMS Challenge - Day 028 (2026-11-18)
-- Topic: Concurrency - Distributed Advisory Locks & Leader Election
-- Category: Distributed Coordination & Application-Level Locking
-- RDBMS Compatibility: PostgreSQL (pg_advisory_lock), MySQL (GET_LOCK), SQLite
-- ============================================================================

-- Row-level locking (SELECT ... FOR UPDATE) requires an existing row in a table
-- and holds transaction locks open, consuming database buffers and risking deadlocks.
--
-- ADVISORY LOCKS provide lightweight, application-defined mutual exclusion:
-- 1. Leader Election: Guarantee only ONE worker executes a scheduled batch job.
-- 2. Zero Table Lock Overhead: Coordinated purely via lock identifiers.
-- 3. Fencing Tokens: Monotonically increasing numbers attached to every granted lease
--    to prevent zombie/partitioned workers from writing stale data (Split-Brain protection).

.headers on
.mode box

-- ----------------------------------------------------------------------------
-- 1. DISTRIBUTED ADVISORY LOCK REGISTRY
-- ----------------------------------------------------------------------------
DROP TABLE IF EXISTS shared_job_state;
DROP TABLE IF EXISTS distributed_advisory_locks;

CREATE TABLE distributed_advisory_locks (
    lock_name VARCHAR(100) PRIMARY KEY,
    owner_node VARCHAR(50) NOT NULL,
    acquired_at TIMESTAMP NOT NULL,
    expires_at TIMESTAMP NOT NULL,
    fencing_token INTEGER NOT NULL DEFAULT 1
);

-- Target business state table protected by the distributed lock
CREATE TABLE shared_job_state (
    job_id VARCHAR(50) PRIMARY KEY,
    last_run_by VARCHAR(50) NOT NULL,
    highest_fencing_token INT NOT NULL,
    last_completed_at TIMESTAMP NOT NULL
);

INSERT INTO shared_job_state VALUES ('DAILY_INVOICE_SYNC', 'SYSTEM_INIT', 0, '2026-11-17 00:00:00');

-- ----------------------------------------------------------------------------
-- 2. SCENARIO 1: NODE-ALPHA ACQUIRES ADVISORY LOCK (TRY_LOCK)
-- ----------------------------------------------------------------------------
-- Current Simulated Time: '2026-11-18 08:00:00' (Lease duration: 15 seconds)
INSERT INTO distributed_advisory_locks (lock_name, owner_node, acquired_at, expires_at, fencing_token)
VALUES ('LOCK:DAILY_INVOICE_SYNC', 'Worker-Node-Alpha', '2026-11-18 08:00:00', '2026-11-18 08:00:15', 1);

-- Verify lock held by Node-Alpha
SELECT 
    'LOCK_GRANTED' AS outcome,
    lock_name,
    owner_node AS leader_node,
    fencing_token,
    acquired_at,
    expires_at
FROM distributed_advisory_locks
WHERE lock_name = 'LOCK:DAILY_INVOICE_SYNC';

-- ----------------------------------------------------------------------------
-- 3. SCENARIO 2: NODE-BETA ATTEMPTS TO ACQUIRE ACTIVE LOCK (TRY_LOCK FAILS)
-- ----------------------------------------------------------------------------
-- Node-Beta tries at '2026-11-18 08:00:05' (active lease until 08:00:15)
-- The query safely rejects Node-Beta without blocking:
SELECT 
    CASE 
        WHEN COUNT(*) > 0 THEN 'ACQUISITION_REJECTED: Lock currently held by ' || owner_node
        ELSE 'LOCK_AVAILABLE'
    END AS beta_attempt_outcome
FROM distributed_advisory_locks
WHERE lock_name = 'LOCK:DAILY_INVOICE_SYNC'
  AND '2026-11-18 08:00:05' < expires_at;

-- ----------------------------------------------------------------------------
-- 4. SCENARIO 3: NODE-ALPHA EXECUTES BATCH JOB WITH FENCING TOKEN VALIDATION
-- ----------------------------------------------------------------------------
-- Downstream validation: Reject writes if fencing_token <= highest_fencing_token
UPDATE shared_job_state
SET last_run_by = 'Worker-Node-Alpha',
    highest_fencing_token = 1,
    last_completed_at = '2026-11-18 08:00:10'
WHERE job_id = 'DAILY_INVOICE_SYNC'
  AND 1 > highest_fencing_token; -- Fencing token invariant

-- ----------------------------------------------------------------------------
-- 5. SCENARIO 4: LEASE EXPIRES & NODE-GAMMA ASSUMES LEADERSHIP
-- ----------------------------------------------------------------------------
-- At '2026-11-18 08:00:20', previous lease has expired!
-- Node-Gamma detects expired lease and acquires lock, incrementing fencing token to 2:
UPDATE distributed_advisory_locks
SET owner_node = 'Worker-Node-Gamma',
    acquired_at = '2026-11-18 08:00:20',
    expires_at = '2026-11-18 08:00:35',
    fencing_token = fencing_token + 1
WHERE lock_name = 'LOCK:DAILY_INVOICE_SYNC'
  AND '2026-11-18 08:00:20' >= expires_at;

-- Verify Node-Gamma is new leader with fencing token = 2
SELECT 
    'NEW_LEADER_ELECTED' AS status,
    lock_name,
    owner_node AS new_leader,
    fencing_token AS current_fencing_token,
    acquired_at,
    expires_at
FROM distributed_advisory_locks
WHERE lock_name = 'LOCK:DAILY_INVOICE_SYNC';

-- ----------------------------------------------------------------------------
-- 6. SCENARIO 5: ZOMBIE PROTECTION VIA FENCING TOKEN
-- ----------------------------------------------------------------------------
-- Node-Alpha (recovered from pause) attempts to write using stale fencing token = 1
-- The condition '1 > highest_fencing_token' (where highest is 2) evaluates to FALSE!
-- Row count = 0 -> Data corruption prevented!
UPDATE shared_job_state
SET last_run_by = 'Worker-Node-Alpha-Zombie',
    last_completed_at = '2026-11-18 08:00:25'
WHERE job_id = 'DAILY_INVOICE_SYNC'
  AND 1 > highest_fencing_token;

SELECT 
    job_id,
    last_run_by,
    highest_fencing_token,
    last_completed_at,
    'ZOMBIE_MUTATION_BLOCKED_SUCCESSFULLY' AS split_brain_protection
FROM shared_job_state
WHERE job_id = 'DAILY_INVOICE_SYNC';
