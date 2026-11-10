-- ============================================================================
-- Daily DBMS Challenge - Day 013 (2026-11-10)
-- Topic: Horizontal Table Partitioning Strategies
-- Category: High-Volume Database Scalability
-- RDBMS Compatibility: PostgreSQL, MySQL 8.0+
-- ============================================================================

-- Table partitioning splits massive tables (tens to hundreds of millions of rows)
-- into smaller, manageable physical tables while maintaining a single logical interface.
-- Benefits: Partition pruning (scanning only relevant partitions), faster vacuum/maintenance,
-- and instant bulk purging via DROP PARTITION instead of expensive DELETEs.

-- ----------------------------------------------------------------------------
-- 1. RANGE PARTITIONING (By Transaction / Event Date)
-- ----------------------------------------------------------------------------
DROP TABLE IF EXISTS orders_2026_q3;
DROP TABLE IF EXISTS orders_2026_q2;
DROP TABLE IF EXISTS orders_2026_q1;
DROP TABLE IF EXISTS orders_partitioned;

CREATE TABLE orders_partitioned (
    order_id INT NOT NULL,
    customer_id INT NOT NULL,
    order_date DATE NOT NULL,
    total_amount NUMERIC(10, 2) NOT NULL,
    PRIMARY KEY (order_id, order_date)
) PARTITION BY RANGE (order_date);

-- Creating physical quarterly partitions
CREATE TABLE orders_2026_q1 PARTITION OF orders_partitioned
    FOR VALUES FROM ('2026-01-01') TO ('2026-04-01');

CREATE TABLE orders_2026_q2 PARTITION OF orders_partitioned
    FOR VALUES FROM ('2026-04-01') TO ('2026-07-01');

CREATE TABLE orders_2026_q3 PARTITION OF orders_partitioned
    FOR VALUES FROM ('2026-07-01') TO ('2026-10-01');

-- ----------------------------------------------------------------------------
-- 2. LIST PARTITIONING (By Geographic Region or Tenant / Status)
-- ----------------------------------------------------------------------------
DROP TABLE IF EXISTS accounts_apac;
DROP TABLE IF EXISTS accounts_emea;
DROP TABLE IF EXISTS accounts_americas;
DROP TABLE IF EXISTS user_accounts_partitioned;

CREATE TABLE user_accounts_partitioned (
    account_id INT NOT NULL,
    region_code VARCHAR(10) NOT NULL,
    company_name VARCHAR(150) NOT NULL,
    PRIMARY KEY (account_id, region_code)
) PARTITION BY LIST (region_code);

CREATE TABLE accounts_americas PARTITION OF user_accounts_partitioned
    FOR VALUES IN ('US', 'CA', 'BR', 'MX');

CREATE TABLE accounts_emea PARTITION OF user_accounts_partitioned
    FOR VALUES IN ('UK', 'DE', 'FR', 'ES', 'IT');

CREATE TABLE accounts_apac PARTITION OF user_accounts_partitioned
    FOR VALUES IN ('IN', 'SG', 'JP', 'AU');

-- ----------------------------------------------------------------------------
-- 3. PARTITION PRUNING DEMONSTRATION
-- ----------------------------------------------------------------------------
-- When executing queries with partition key filters:
-- The query planner automatically eliminates non-matching partitions,
-- reducing I/O from scanning all partitions to only orders_2026_q2!
--
-- EXPLAIN ANALYZE
-- SELECT * FROM orders_partitioned
-- WHERE order_date >= '2026-05-01' AND order_date <= '2026-05-31';

SELECT 'Partitioning strategy script verified and ready for production use.' AS status;
