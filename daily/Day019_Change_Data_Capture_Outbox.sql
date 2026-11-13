-- ============================================================================
-- Daily DBMS Challenge - Day 019 (2026-11-12)
-- Topic: Distributed Systems - Change Data Capture (CDC) & Transactional Outbox Pattern
-- Category: System Architecture & Event-Driven Data Pipelines
-- RDBMS Compatibility: PostgreSQL, SQLite, MySQL 8.0+, Oracle
-- ============================================================================

-- The "Dual-Write Problem" occurs when an application must both persist data in a
-- relational database AND emit an event to a message broker (e.g. Apache Kafka, RabbitMQ).
-- If the DB commit succeeds but message publishing crashes, state diverges permanently.
--
-- The TRANSACTIONAL OUTBOX PATTERN guarantees at-least-once message delivery by saving
-- the event payload directly into an `outbox_events` table inside the exact same local
-- database transaction. A separate relay worker (or CDC engine like Debezium) streams
-- outbox rows to the broker.

.headers on
.mode box

-- ----------------------------------------------------------------------------
-- 1. BASE BUSINESS TABLES & TRANSACTIONAL OUTBOX TABLE
-- ----------------------------------------------------------------------------
DROP TABLE IF EXISTS outbox_events;
DROP TABLE IF EXISTS customer_orders;

CREATE TABLE customer_orders (
    order_id INT PRIMARY KEY,
    customer_id INT NOT NULL,
    total_amount NUMERIC(10, 2) NOT NULL,
    order_status VARCHAR(30) NOT NULL,
    created_at TIMESTAMP NOT NULL
);

CREATE TABLE outbox_events (
    event_id INTEGER PRIMARY KEY AUTOINCREMENT,
    aggregate_type VARCHAR(50) NOT NULL,       -- e.g. 'ORDER', 'INVOICE', 'USER'
    aggregate_id INT NOT NULL,                -- Foreign business entity ID
    event_type VARCHAR(50) NOT NULL,           -- e.g. 'OrderCreated', 'OrderCancelled'
    payload_json TEXT NOT NULL,                -- Serialized JSON event data
    status VARCHAR(20) NOT NULL DEFAULT 'PENDING', -- PENDING, PUBLISHED, FAILED
    retry_count INT NOT NULL DEFAULT 0,
    created_at TIMESTAMP NOT NULL,
    processed_at TIMESTAMP NULL
);

-- Indexing for high-throughput Outbox Poller relay
CREATE INDEX idx_outbox_pending ON outbox_events (status, created_at);

-- ----------------------------------------------------------------------------
-- 2. ATOMIC TRANSACTION: SIMULATE PLACING AN ORDER AND WRITING TO OUTBOX
-- ----------------------------------------------------------------------------
-- Both writes succeed or both rollback together
BEGIN TRANSACTION;

-- Step A: Write to domain business table
INSERT INTO customer_orders (order_id, customer_id, total_amount, order_status, created_at)
VALUES (9001, 401, 349.99, 'CREATED', '2026-11-12 10:15:00');

-- Step B: Write event payload to outbox table inside same atomic transaction
INSERT INTO outbox_events (aggregate_type, aggregate_id, event_type, payload_json, status, created_at)
VALUES (
    'ORDER', 
    9001, 
    'OrderCreated', 
    '{"orderId": 9001, "customerId": 401, "amount": 349.99, "currency": "USD", "items": 3}', 
    'PENDING', 
    '2026-11-12 10:15:00'
);

COMMIT;

-- Simulate second order
BEGIN TRANSACTION;
INSERT INTO customer_orders (order_id, customer_id, total_amount, order_status, created_at)
VALUES (9002, 402, 89.50, 'CREATED', '2026-11-12 10:18:22');

INSERT INTO outbox_events (aggregate_type, aggregate_id, event_type, payload_json, status, created_at)
VALUES (
    'ORDER', 
    9002, 
    'OrderCreated', 
    '{"orderId": 9002, "customerId": 402, "amount": 89.50, "currency": "USD", "items": 1}', 
    'PENDING', 
    '2026-11-12 10:18:22'
);
COMMIT;

-- ----------------------------------------------------------------------------
-- 3. QUERY 1: OUTBOX POLLER BATCH QUERY
-- ----------------------------------------------------------------------------
-- Relay worker pulls unprocessed events ordered by FIFO timestamp
SELECT 
    event_id,
    aggregate_type,
    aggregate_id,
    event_type,
    payload_json,
    status,
    created_at
FROM outbox_events
WHERE status = 'PENDING'
ORDER BY created_at ASC
LIMIT 10;

-- ----------------------------------------------------------------------------
-- 4. SIMULATE RELAY WORKER PROCESSING: MARK EVENT 1 AS PUBLISHED
-- ----------------------------------------------------------------------------
UPDATE outbox_events
SET status = 'PUBLISHED',
    processed_at = '2026-11-12 10:15:05'
WHERE event_id = 1;

-- ----------------------------------------------------------------------------
-- 5. QUERY 2: RELAY STATUS DASHBOARD (MONITOR LAG & PENDING QUEUE)
-- ----------------------------------------------------------------------------
SELECT 
    status,
    COUNT(*) AS total_events,
    MIN(created_at) AS oldest_unprocessed,
    MAX(created_at) AS newest_event
FROM outbox_events
GROUP BY status;
