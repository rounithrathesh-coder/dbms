-- ============================================================================
-- REC R2023 IT Curriculum - Unit V: NoSQL Databases & CAP Theorem
-- Topic: SQL vs. NoSQL, CAP Theorem Matrix, Document Modeling (Embedding vs. Referencing)
-- RDBMS Compatibility: PostgreSQL (JSONB), SQLite (json1), MongoDB Conceptual Parity
-- ============================================================================

-- 1. SQL (RDBMS) vs. NoSQL Paradigm:
-- - SQL: Fixed schema, ACID transactions, Normalization (1NF–3NF), Joins.
-- - NoSQL (Document/Key-Value): Flexible schema, BASE properties, Denormalization, Horizontal Scaling.
--
-- 2. CAP Theorem (Brewer's Theorem):
-- In any distributed asynchronous network, you can guarantee at most TWO out of three properties:
-- - Consistency (C): All nodes see the exact same data at the same moment.
-- - Availability (A): Every non-failing node returns a non-error response.
-- - Partition Tolerance (P): The system functions despite dropped network packets.
-- Since network partitions (P) are physically unavoidable across distributed networks,
-- a system must choose between CP (e.g. MongoDB, HBase) or AP (e.g. Cassandra, DynamoDB, CouchDB).

.headers on
.mode box

-- ----------------------------------------------------------------------------
-- 1. CAP THEOREM CLASSIFICATION MATRIX
-- ----------------------------------------------------------------------------
DROP TABLE IF EXISTS cap_systems_taxonomy;

CREATE TABLE cap_systems_taxonomy (
    database_system VARCHAR(30) PRIMARY KEY,
    cap_profile VARCHAR(10) NOT NULL,      -- 'CA', 'CP', 'AP'
    consistency_model VARCHAR(50) NOT NULL,
    failover_behavior TEXT NOT NULL
);

INSERT INTO cap_systems_taxonomy VALUES
('PostgreSQL / Oracle (Single)', 'CA', 'Strict ACID Serializable', 'Non-distributed. Cannot survive network partition between separate nodes.'),
('MongoDB / HBase / Spanner',   'CP', 'Linearizable / Strong Read', 'Elects new primary on partition. Pauses writes during election to ensure Consistency.'),
('Apache Cassandra / DynamoDB', 'AP', 'Eventual Consistency',       'Accepts writes across all partitioned nodes. Reconciles conflicts later via vector clocks.');

SELECT * FROM cap_systems_taxonomy;

-- ----------------------------------------------------------------------------
-- 2. DOCUMENT DATA MODELING: EMBEDDING VS REFERENCING (1-TO-MANY RELATIONSHIPS)
-- ----------------------------------------------------------------------------
-- Approach A: Referencing (Normalized RDBMS Style)
-- Good for unbounded growth (e.g. 1 million logs per user)
-- Approach B: Embedding (Denormalized Document Style)
-- Good for 1-to-few bounded data accessed together in a single atomic disk read!

DROP TABLE IF EXISTS customer_orders_docstore;

CREATE TABLE customer_orders_docstore (
    order_id INT PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL,
    document_json TEXT NOT NULL -- BSON-equivalent JSON payload
);

-- Seed embedded document (items array embedded directly inside the order document)
INSERT INTO customer_orders_docstore VALUES
(5001, 'Rounith Rathesh', '{
    "customerId": 101,
    "shippingAddress": {"city": "Chennai", "state": "Tamil Nadu", "country": "India"},
    "items": [
        {"sku": "LAPTOP-01", "name": "MacBook Pro", "qty": 1, "price": 1800.00},
        {"sku": "MOUSE-02",  "name": "Wireless Mouse", "qty": 1, "price": 45.00}
    ],
    "paymentMethod": "UPI",
    "isFulfilled": true
}');

-- Querying into embedded document fields using standard JSON functions:
SELECT 
    order_id,
    customer_name,
    json_extract(document_json, '$.shippingAddress.city') AS shipping_city,
    json_extract(document_json, '$.paymentMethod') AS payment_type,
    json_array_length(json_extract(document_json, '$.items')) AS total_item_count,
    ROUND(
        json_extract(document_json, '$.items[0].price') * json_extract(document_json, '$.items[0].qty') +
        json_extract(document_json, '$.items[1].price') * json_extract(document_json, '$.items[1].qty'), 2
    ) AS calculated_order_total
FROM customer_orders_docstore;
