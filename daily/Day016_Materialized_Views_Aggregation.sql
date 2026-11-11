-- ============================================================================
-- Daily DBMS Challenge - Day 016 (2026-11-11)
-- Topic: Materialized Views, Summary Rollups & Concurrent Refresh Strategies
-- Category: High-Performance Analytics & Query Caching
-- RDBMS Compatibility: PostgreSQL, Oracle, SQLite (Summary Table Pattern), MySQL
-- ============================================================================

-- A standard View is simply a saved query executed on-demand.
-- In contrast, a MATERIALIZED VIEW physically persists the precomputed query results
-- to disk and indexes them, transforming multi-second analytical aggregations into
-- sub-millisecond index lookups.

-- ----------------------------------------------------------------------------
-- 1. BASE SCHEMA & MASSIVE TRANSACTIONS SIMULATION
-- ----------------------------------------------------------------------------
DROP TABLE IF EXISTS order_transactions;
DROP TABLE IF EXISTS merchants;

CREATE TABLE merchants (
    merchant_id INT PRIMARY KEY,
    business_name VARCHAR(150) NOT NULL,
    category VARCHAR(50) NOT NULL
);

CREATE TABLE order_transactions (
    txn_id INT PRIMARY KEY,
    merchant_id INT NOT NULL,
    customer_id INT NOT NULL,
    amount NUMERIC(10, 2) NOT NULL,
    status VARCHAR(20) NOT NULL,
    created_at TIMESTAMP NOT NULL,
    FOREIGN KEY (merchant_id) REFERENCES merchants(merchant_id)
);

-- Seed Merchants
INSERT INTO merchants VALUES
(1, 'Apex Electronics', 'Retail'),
(2, 'Cloud Coffee Co', 'Food & Beverage'),
(3, 'Pulse Fitness', 'Health & Wellness');

-- Seed Sample Transactions
INSERT INTO order_transactions VALUES
(101, 1, 501, 299.99, 'SUCCESS', '2026-11-01 10:15:00'),
(102, 1, 502, 149.50, 'SUCCESS', '2026-11-01 11:30:00'),
(103, 1, 503, 75.00,  'REFUNDED', '2026-11-01 12:00:00'),
(104, 2, 504, 12.50,  'SUCCESS', '2026-11-01 12:45:00'),
(105, 2, 505, 8.75,   'SUCCESS', '2026-11-01 13:10:00'),
(106, 3, 506, 65.00,  'SUCCESS', '2026-11-01 14:00:00'),
(107, 1, 507, 450.00, 'SUCCESS', '2026-11-02 09:30:00');

-- ----------------------------------------------------------------------------
-- 2. MATERIALIZED VIEW DEFINITION (PostgreSQL / Enterprise RDBMS)
-- ----------------------------------------------------------------------------
-- Precomputes total revenue, average order value (AOV), and successful order count:
--
-- CREATE MATERIALIZED VIEW mv_merchant_daily_metrics AS
-- SELECT 
--     m.merchant_id,
--     m.business_name,
--     m.category,
--     DATE(ot.created_at) AS metric_date,
--     COUNT(ot.txn_id) AS total_txns,
--     SUM(CASE WHEN ot.status = 'SUCCESS' THEN ot.amount ELSE 0 END) AS net_revenue,
--     ROUND(AVG(CASE WHEN ot.status = 'SUCCESS' THEN ot.amount ELSE NULL END), 2) AS avg_order_value
-- FROM merchants m
-- JOIN order_transactions ot ON m.merchant_id = ot.merchant_id
-- GROUP BY m.merchant_id, m.business_name, m.category, DATE(ot.created_at);
--
-- ----------------------------------------------------------------------------
-- 3. UNIQUE INDEX FOR CONCURRENT REFRESH
-- ----------------------------------------------------------------------------
-- A unique index is mandatory to enable zero-downtime concurrent refreshes!
-- CREATE UNIQUE INDEX idx_mv_merchant_daily_uid 
-- ON mv_merchant_daily_metrics(merchant_id, metric_date);
--
-- REFRESH MATERIALIZED VIEW CONCURRENTLY mv_merchant_daily_metrics;

-- ----------------------------------------------------------------------------
-- 4. PORTABLE SUMMARY TABLE PATTERN (ANSI SQL & SQLite Compatible)
-- ----------------------------------------------------------------------------
DROP TABLE IF EXISTS mv_merchant_daily_metrics;

CREATE TABLE mv_merchant_daily_metrics (
    merchant_id INT NOT NULL,
    business_name VARCHAR(150) NOT NULL,
    category VARCHAR(50) NOT NULL,
    metric_date DATE NOT NULL,
    total_txns INT NOT NULL,
    net_revenue NUMERIC(10, 2) NOT NULL,
    avg_order_value NUMERIC(10, 2) NOT NULL,
    PRIMARY KEY (merchant_id, metric_date)
);

-- Initial Population (Atomic Refresh Procedure Simulation)
INSERT INTO mv_merchant_daily_metrics
SELECT 
    m.merchant_id,
    m.business_name,
    m.category,
    DATE(ot.created_at) AS metric_date,
    COUNT(ot.txn_id) AS total_txns,
    SUM(CASE WHEN ot.status = 'SUCCESS' THEN ot.amount ELSE 0 END) AS net_revenue,
    ROUND(AVG(CASE WHEN ot.status = 'SUCCESS' THEN ot.amount ELSE NULL END), 2) AS avg_order_value
FROM merchants m
JOIN order_transactions ot ON m.merchant_id = ot.merchant_id
GROUP BY m.merchant_id, m.business_name, m.category, DATE(ot.created_at);

-- Querying the Precomputed Summary Table (Sub-millisecond analytical latency)
SELECT 
    business_name,
    category,
    metric_date,
    total_txns,
    net_revenue,
    avg_order_value
FROM mv_merchant_daily_metrics
ORDER BY net_revenue DESC;
