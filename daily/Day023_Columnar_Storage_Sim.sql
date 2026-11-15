-- ============================================================================
-- Daily DBMS Challenge - Day 023 (2026-11-15)
-- Topic: Storage Engines - Columnar Compression & Vectorized Aggregations
-- Category: Database Architecture & Analytical Storage Engines (OLTP vs OLAP)
-- RDBMS Compatibility: PostgreSQL, SQLite, MySQL 8.0+, ClickHouse/DuckDB Principles
-- ============================================================================

-- In traditional Row-Oriented OLTP databases (PostgreSQL, MySQL, SQLite), entire tuples
-- are stored contiguously on disk blocks. This excels for transactional writes (INSERT/UPDATE),
-- but causes severe I/O bottlenecks for analytical aggregations (SUM, AVG) because the
-- database must read wide text fields, addresses, and unused columns into memory.
--
-- Column-Oriented OLAP systems (ClickHouse, Snowflake, DuckDB, Apache Parquet) store
-- each column in its own contiguous physical vector.
-- Key Advantages:
-- 1. I/O Pruning: Only the columns referenced in SELECT/WHERE are fetched from disk.
-- 2. High Compression: Homogeneous data types compress tightly via Dictionary Encoding
--    and Run-Length Encoding (RLE).
-- 3. SIMD / Vectorized Execution: CPU vector instructions process multiple values per cycle.

.headers on
.mode box

-- ----------------------------------------------------------------------------
-- 1. ROW-STORE ARCHITECTURE SIMULATION (TRADITIONAL OLTP)
-- ----------------------------------------------------------------------------
DROP TABLE IF EXISTS orders_row_store;

CREATE TABLE orders_row_store (
    order_id INT PRIMARY KEY,
    customer_id INT NOT NULL,
    amount NUMERIC(10, 2) NOT NULL,
    status VARCHAR(20) NOT NULL,
    shipping_notes TEXT NOT NULL,
    created_at TIMESTAMP NOT NULL
);

-- Seed row-oriented orders (includes wide text columns)
INSERT INTO orders_row_store VALUES
(1001, 501, 149.50, 'COMPLETED', 'Fragile electronic equipment. Leave at front door.', '2026-11-01 10:00:00'),
(1002, 502,  25.00, 'COMPLETED', 'Standard package delivery. Gate code #4912.',        '2026-11-01 10:05:00'),
(1003, 503, 499.99, 'REFUNDED',  'Customer returned package damaged during transit.',   '2026-11-01 10:15:00'),
(1004, 504,  89.00, 'COMPLETED', 'Signature required upon delivery.',                  '2026-11-01 10:20:00'),
(1005, 505,  12.50, 'CANCELLED', 'Order cancelled before payment authorization.',       '2026-11-01 10:30:00'),
(1006, 506, 320.00, 'COMPLETED', 'Priority express overnight shipping.',                '2026-11-01 10:45:00');

-- ----------------------------------------------------------------------------
-- 2. COLUMN-STORE ARCHITECTURE SIMULATION (DECOMPOSED STORAGE MODEL)
-- ----------------------------------------------------------------------------
-- In Columnar storage, columns are partitioned into isolated homogeneous arrays
DROP TABLE IF EXISTS col_order_status_dict;
DROP TABLE IF EXISTS col_orders_status;
DROP TABLE IF EXISTS col_orders_amount;

-- Dictionary Encoding Table (Maps strings to 1-byte integer IDs)
CREATE TABLE col_order_status_dict (
    status_id INT PRIMARY KEY,
    status_label VARCHAR(20) NOT NULL
);

INSERT INTO col_order_status_dict VALUES
(1, 'COMPLETED'),
(2, 'CANCELLED'),
(3, 'REFUNDED');

-- Column 1: Amounts Vector (Contiguous doubles/numerics)
CREATE TABLE col_orders_amount (
    row_id INT PRIMARY KEY,
    amount NUMERIC(10, 2) NOT NULL
);

-- Column 2: Status Vector (Contiguous integer foreign keys to dictionary)
CREATE TABLE col_orders_status (
    row_id INT PRIMARY KEY,
    status_id INT NOT NULL,
    FOREIGN KEY (status_id) REFERENCES col_order_status_dict(status_id)
);

-- Seed Columnar Vectors
INSERT INTO col_orders_amount VALUES
(1, 149.50), (2, 25.00), (3, 499.99), (4, 89.00), (5, 12.50), (6, 320.00);

INSERT INTO col_orders_status VALUES
(1, 1), (2, 1), (3, 3), (4, 1), (5, 2), (6, 1);

-- ----------------------------------------------------------------------------
-- 3. QUERY 1: ANALYTICAL AGGREGATION COMPARISON
-- ----------------------------------------------------------------------------
-- In row-store, the DB engine must scan the entire row (including wide text):
SELECT 
    'ROW_STORE_SCAN' AS scan_mode,
    COUNT(*) AS total_orders,
    SUM(amount) AS total_revenue,
    ROUND(AVG(amount), 2) AS avg_ticket,
    MIN(amount) AS min_order,
    MAX(amount) AS max_order
FROM orders_row_store
WHERE status = 'COMPLETED';

-- In column-store, the engine ONLY scans col_orders_status and col_orders_amount:
SELECT 
    'COLUMN_STORE_SCAN' AS scan_mode,
    COUNT(*) AS total_orders,
    SUM(a.amount) AS total_revenue,
    ROUND(AVG(a.amount), 2) AS avg_ticket,
    MIN(a.amount) AS min_order,
    MAX(a.amount) AS max_order
FROM col_orders_amount a
JOIN col_orders_status s ON a.row_id = s.row_id
WHERE s.status_id = 1; -- 1 = 'COMPLETED' (Filtered directly via integer comparison)

-- ----------------------------------------------------------------------------
-- 4. QUERY 2: RUN-LENGTH ENCODING (RLE) COMPRESSION DEMONSTRATION
-- ----------------------------------------------------------------------------
-- Run-Length Encoding compresses sorted sequences of identical values into
-- (value, run_length) pairs, reducing storage from O(N) to O(distinct_runs).
WITH StatusRuns AS (
    SELECT 
        status,
        order_id,
        ROW_NUMBER() OVER (ORDER BY status, order_id) -
        ROW_NUMBER() OVER (PARTITION BY status ORDER BY order_id) AS run_group
    FROM orders_row_store
)
SELECT 
    status,
    COUNT(*) AS run_length,
    'Compressed (' || status || ' x ' || COUNT(*) || ')' AS rle_encoded_block
FROM StatusRuns
GROUP BY status, run_group
ORDER BY status;

-- ----------------------------------------------------------------------------
-- 5. QUERY 3: I/O FOOTPRINT & STORAGE REDUCTION AUDIT
-- ----------------------------------------------------------------------------
-- Calculate estimated byte scan footprint:
-- Row store: order_id(4) + cust_id(4) + amount(8) + status(10) + text(50) = ~76 bytes/row
-- Column store for revenue query: status_id(1) + amount(8) = 9 bytes/row (~88% reduction!)
SELECT 
    'Row-Store Scan' AS storage_type,
    COUNT(*) * 76 AS estimated_bytes_scanned,
    '100%' AS baseline_io
FROM orders_row_store
UNION ALL
SELECT 
    'Column-Store Scan' AS storage_type,
    COUNT(*) * 9 AS estimated_bytes_scanned,
    ROUND((COUNT(*) * 9.0) / (COUNT(*) * 76.0) * 100, 1) || '% of baseline' AS baseline_io
FROM orders_row_store;
