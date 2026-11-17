-- ============================================================================
-- Daily DBMS Challenge - Day 026 (2026-11-17)
-- Topic: Data Warehousing - Bitmap Indexing & Bitwise Boolean Query Evaluation
-- Category: Analytical Indexing & Low-Cardinality Filtering
-- RDBMS Compatibility: PostgreSQL, SQLite, MySQL 8.0+, Oracle
-- ============================================================================

-- B-Trees are ideal for high-cardinality keys (e.g. user_id, order_id).
-- However, in analytical data warehouses, queries frequently filter across
-- multiple low-cardinality columns (e.g. gender: 2 values, is_subscriber: 2 values,
-- region: 5 values, customer_tier: 4 values).
--
-- BITMAP INDEXES represent each distinct value as a vector of bits (1 or 0)
-- corresponding to row IDs. Multiple filters can be answered purely via ultra-fast
-- CPU bitwise operations (AND, OR, NOT, POPCOUNT) without reading table rows!

.headers on
.mode box

-- ----------------------------------------------------------------------------
-- 1. ANALYTICAL CUSTOMER DIMENSION TABLE
-- ----------------------------------------------------------------------------
DROP TABLE IF EXISTS customer_bitmap_dim;

CREATE TABLE customer_bitmap_dim (
    cust_id INTEGER PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    region VARCHAR(10) NOT NULL,        -- 'NORTH', 'SOUTH', 'EAST', 'WEST'
    tier VARCHAR(10) NOT NULL,          -- 'GOLD', 'SILVER', 'BRONZE'
    is_active INT NOT NULL,             -- 1 or 0
    has_credit_card INT NOT NULL        -- 1 or 0
);

-- Seed 8 customers
INSERT INTO customer_bitmap_dim VALUES
(1, 'Alice Chen',   'NORTH', 'GOLD',   1, 1),
(2, 'Bob Martin',   'SOUTH', 'SILVER', 1, 0),
(3, 'Carla Gomez',  'NORTH', 'SILVER', 0, 1),
(4, 'David Patel',  'EAST',  'GOLD',   1, 1),
(5, 'Eva Rossi',    'NORTH', 'GOLD',   1, 0),
(6, 'Frank Miller', 'WEST',  'BRONZE', 0, 0),
(7, 'Grace Lin',    'SOUTH', 'GOLD',   1, 1),
(8, 'Henry Ford',   'EAST',  'BRONZE', 1, 1);

-- ----------------------------------------------------------------------------
-- 2. BITMAP VECTOR SIMULATION (8-BIT BITMASKS FOR CUSTOMERS 1..8)
-- ----------------------------------------------------------------------------
-- In bitmap indexing, each attribute value maps to a bitmask:
-- Bit position 0: Cust 1, Bit position 1: Cust 2, ..., Bit position 7: Cust 8.
-- Let's construct the bitmasks dynamically in SQL!

-- ----------------------------------------------------------------------------
-- 3. QUERY 1: DYNAMIC BITMAP VECTOR GENERATION
-- ----------------------------------------------------------------------------
WITH BitVectors AS (
    SELECT 
        'REGION = NORTH' AS predicate,
        -- Binary representation string for customers 1 through 8
        GROUP_CONCAT(CASE WHEN region = 'NORTH' THEN '1' ELSE '0' END, '') AS bit_pattern
    FROM customer_bitmap_dim
    UNION ALL
    SELECT 
        'TIER = GOLD' AS predicate,
        GROUP_CONCAT(CASE WHEN tier = 'GOLD' THEN '1' ELSE '0' END, '') AS bit_pattern
    FROM customer_bitmap_dim
    UNION ALL
    SELECT 
        'IS_ACTIVE = 1' AS predicate,
        GROUP_CONCAT(CASE WHEN is_active = 1 THEN '1' ELSE '0' END, '') AS bit_pattern
    FROM customer_bitmap_dim
    UNION ALL
    SELECT 
        'HAS_CREDIT_CARD = 1' AS predicate,
        GROUP_CONCAT(CASE WHEN has_credit_card = 1 THEN '1' ELSE '0' END, '') AS bit_pattern
    FROM customer_bitmap_dim
)
SELECT * FROM BitVectors;

-- ----------------------------------------------------------------------------
-- 4. QUERY 2: BITWISE INTERSECTION (AND) QUERY
-- ----------------------------------------------------------------------------
-- Business Question: Find all customers where REGION='NORTH' AND TIER='GOLD' AND IS_ACTIVE=1
-- Bitmap Index performs:
--   NORTH:    10101000
--   GOLD:     10011010
--   ACTIVE:   11011011
--   Bitwise AND = 10001000 -> Customer #1 and Customer #5 match!
SELECT 
    cust_id,
    name,
    region,
    tier,
    is_active,
    has_credit_card
FROM customer_bitmap_dim
WHERE region = 'NORTH'
  AND tier = 'GOLD'
  AND is_active = 1;

-- ----------------------------------------------------------------------------
-- 5. QUERY 3: BITMAP AGGREGATION & CARDINALITY (COUNT VIA BITWISE POPCOUNT)
-- ----------------------------------------------------------------------------
SELECT 
    region,
    tier,
    COUNT(*) AS customer_count,
    ROUND(AVG(is_active) * 100, 1) || '%' AS active_rate,
    ROUND(AVG(has_credit_card) * 100, 1) || '%' AS credit_card_rate
FROM customer_bitmap_dim
GROUP BY region, tier
ORDER BY customer_count DESC;
