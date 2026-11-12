-- ============================================================================
-- Daily DBMS Challenge - Day 018 (2026-11-12)
-- Topic: Slowly Changing Dimensions (SCD Type 2) & Temporal Point-in-Time Queries
-- Category: Data Warehousing, Temporal Modeling & Audit Systems
-- RDBMS Compatibility: PostgreSQL, SQLite, MySQL 8.0+, Oracle
-- ============================================================================

-- In transactional and analytical systems, entities mutate over time.
-- An in-place UPDATE overwrites historical context, making retroactive auditing,
-- compliance verification, and point-in-time financial reporting impossible.
--
-- SCD Type 2 (Slowly Changing Dimensions) preserves the complete evolution of an
-- entity by adding new rows with validity intervals [valid_from, valid_to) and
-- an active indicator flag (is_current).

.headers on
.mode box

-- ----------------------------------------------------------------------------
-- 1. BASE SCHEMA DEFINITION
-- ----------------------------------------------------------------------------
DROP TABLE IF EXISTS customer_account_scd2;

CREATE TABLE customer_account_scd2 (
    surrogate_key INTEGER PRIMARY KEY AUTOINCREMENT,
    customer_id INT NOT NULL,
    full_name VARCHAR(100) NOT NULL,
    tier VARCHAR(20) NOT NULL,            -- Bronze, Silver, Gold, Platinum
    credit_limit NUMERIC(10, 2) NOT NULL,
    city VARCHAR(100) NOT NULL,
    valid_from TIMESTAMP NOT NULL,
    valid_to TIMESTAMP NOT NULL,          -- '9999-12-31 23:59:59' represents open-ended active record
    is_current INT NOT NULL CHECK (is_current IN (0, 1))
);

-- Recommended Indexing Strategy for SCD Type 2:
-- 1. Point-in-time lookups: (customer_id, valid_from, valid_to)
-- 2. Current snapshot lookups: (customer_id, is_current)
CREATE INDEX idx_scd2_temporal ON customer_account_scd2 (customer_id, valid_from, valid_to);
CREATE INDEX idx_scd2_current ON customer_account_scd2 (customer_id, is_current);

-- ----------------------------------------------------------------------------
-- 2. SEED HISTORICAL STATE EVOLUTION FOR CUSTOMERS
-- ----------------------------------------------------------------------------
-- Customer 101: Started in Austin as Silver, upgraded to Gold, moved to Seattle, upgraded to Platinum
INSERT INTO customer_account_scd2 
(customer_id, full_name, tier, credit_limit, city, valid_from, valid_to, is_current)
VALUES
(101, 'Elena Rostova', 'Silver',   5000.00,  'Austin',  '2025-01-01 00:00:00', '2025-06-15 12:00:00', 0),
(101, 'Elena Rostova', 'Gold',     12000.00, 'Austin',  '2025-06-15 12:00:00', '2026-02-01 09:30:00', 0),
(101, 'Elena Rostova', 'Gold',     12000.00, 'Seattle', '2026-02-01 09:30:00', '2026-08-10 16:45:00', 0),
(101, 'Elena Rostova', 'Platinum', 25000.00, 'Seattle', '2026-08-10 16:45:00', '9999-12-31 23:59:59', 1);

-- Customer 102: Started in Boston as Bronze, upgraded to Silver
INSERT INTO customer_account_scd2 
(customer_id, full_name, tier, credit_limit, city, valid_from, valid_to, is_current)
VALUES
(102, 'Marcus Vance', 'Bronze', 2500.00, 'Boston', '2025-03-20 00:00:00', '2026-01-10 14:00:00', 0),
(102, 'Marcus Vance', 'Silver', 6000.00, 'Boston', '2026-01-10 14:00:00', '9999-12-31 23:59:59', 1);

-- ----------------------------------------------------------------------------
-- 3. QUERY 1: CURRENT ACTIVE SNAPSHOT
-- ----------------------------------------------------------------------------
-- High-speed lookup for live operational transactions
SELECT 
    customer_id,
    full_name,
    tier,
    credit_limit,
    city,
    valid_from AS active_since
FROM customer_account_scd2
WHERE is_current = 1
ORDER BY customer_id;

-- ----------------------------------------------------------------------------
-- 4. QUERY 2: TIME-TRAVEL / POINT-IN-TIME RECONSTRUCTION (AS OF '2025-10-01')
-- ----------------------------------------------------------------------------
-- Reconstruct the exact database state as of October 1, 2025:
-- Invariant: valid_from <= target_timestamp < valid_to
SELECT 
    '2025-10-01 00:00:00' AS snapshot_as_of,
    customer_id,
    full_name,
    tier,
    credit_limit,
    city,
    valid_from,
    valid_to
FROM customer_account_scd2
WHERE '2025-10-01 00:00:00' >= valid_from 
  AND '2025-10-01 00:00:00' < valid_to
ORDER BY customer_id;

-- ----------------------------------------------------------------------------
-- 5. QUERY 3: AUDIT TRAIL & ATTRIBUTE DELTA ANALYSIS (USING WINDOW FUNCTIONS)
-- ----------------------------------------------------------------------------
-- Analyze exactly what attribute shifted between successive versions
SELECT 
    customer_id,
    tier AS new_tier,
    LAG(tier, 1, 'INITIAL') OVER (PARTITION BY customer_id ORDER BY valid_from) AS previous_tier,
    credit_limit AS new_limit,
    LAG(credit_limit, 1, 0.00) OVER (PARTITION BY customer_id ORDER BY valid_from) AS previous_limit,
    city AS current_city,
    LAG(city, 1, 'NONE') OVER (PARTITION BY customer_id ORDER BY valid_from) AS previous_city,
    valid_from AS effective_date
FROM customer_account_scd2
WHERE customer_id = 101
ORDER BY valid_from;

-- ----------------------------------------------------------------------------
-- 6. QUERY 4: TEMPORAL INTEGRITY CHECK (VERIFY NO GAPS OR OVERLAPS)
-- ----------------------------------------------------------------------------
-- SCD Type 2 requires consecutive records to have matching boundaries:
-- previous valid_to == current valid_from
WITH TemporalValidation AS (
    SELECT 
        customer_id,
        surrogate_key,
        valid_from,
        valid_to,
        LAG(valid_to) OVER (PARTITION BY customer_id ORDER BY valid_from) AS expected_prev_end
    FROM customer_account_scd2
)
SELECT 
    customer_id,
    surrogate_key,
    valid_from,
    expected_prev_end,
    CASE 
        WHEN expected_prev_end IS NULL THEN 'ROOT_RECORD (OK)'
        WHEN expected_prev_end = valid_from THEN 'SEAMLESS_CONTINUITY (OK)'
        ELSE 'TEMPORAL_ANOMALY_DETECTED'
    END AS integrity_status
FROM TemporalValidation;
