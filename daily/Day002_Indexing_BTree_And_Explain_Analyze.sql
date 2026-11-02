-- ============================================================================
-- Daily DBMS Challenge - Day 002
-- Topic: Query Optimization - Indexing Strategies & EXPLAIN Analysis
-- ============================================================================

DROP TABLE IF EXISTS order_items;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS customers;

CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    email VARCHAR(255) NOT NULL UNIQUE,
    country VARCHAR(50) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT NOT NULL,
    order_date DATE NOT NULL,
    status VARCHAR(20) NOT NULL,
    total_amount NUMERIC(10, 2) NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

-- 1. Single Column Index for fast exact lookups
CREATE INDEX idx_orders_customer_id ON orders(customer_id);

-- 2. Composite (Multi-column) Index (Order matters! Leading column rule)
CREATE INDEX idx_orders_status_date ON orders(status, order_date);

-- 3. Covering Index concept: Index contains all columns requested by query
CREATE INDEX idx_orders_covering ON orders(customer_id, status, total_amount);

-- Sample Query to check execution plan
EXPLAIN QUERY PLAN
SELECT customer_id, SUM(total_amount)
FROM orders
WHERE status = 'COMPLETED' AND order_date >= '2026-01-01'
GROUP BY customer_id;
