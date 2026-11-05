-- ============================================================================
-- Daily DBMS Challenge - Day 008
-- Topic: Concurrency Control - Pessimistic Locking
-- ============================================================================

-- In multi-user concurrent systems, concurrent reads followed by writes can cause
-- Lost Update Anomalies.
-- Syntax in PostgreSQL / MySQL:
-- SELECT balance FROM accounts WHERE id = 1 FOR UPDATE;

DROP TABLE IF EXISTS inventory;

CREATE TABLE inventory (
    item_id INT PRIMARY KEY,
    item_name VARCHAR(100) NOT NULL,
    stock_qty INT NOT NULL CHECK (stock_qty >= 0)
);

INSERT INTO inventory VALUES (101, 'Smartphone Pro', 5);

-- Safe atomic inventory reduction
BEGIN TRANSACTION;
UPDATE inventory
SET stock_qty = stock_qty - 1
WHERE item_id = 101 AND stock_qty >= 1;
COMMIT;

SELECT * FROM inventory;
