-- ============================================================================
-- Daily DBMS Challenge - Day 005
-- Topic: Data Integrity - Triggers & Audit Trails
-- ============================================================================

DROP TABLE IF EXISTS product_price_audit;
DROP TABLE IF EXISTS products;

CREATE TABLE products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100) NOT NULL,
    unit_price NUMERIC(10, 2) NOT NULL
);

CREATE TABLE product_price_audit (
    audit_id INTEGER PRIMARY KEY AUTOINCREMENT,
    product_id INT NOT NULL,
    old_price NUMERIC(10, 2) NOT NULL,
    new_price NUMERIC(10, 2) NOT NULL,
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Trigger: Automatically capture price changes
CREATE TRIGGER trg_audit_price_change
AFTER UPDATE OF unit_price ON products
FOR EACH ROW
WHEN OLD.unit_price <> NEW.unit_price
BEGIN
    INSERT INTO product_price_audit (product_id, old_price, new_price)
    VALUES (OLD.product_id, OLD.unit_price, NEW.unit_price);
END;

-- Test Trigger
INSERT INTO products VALUES (1, 'Mechanical Keyboard', 89.99);
UPDATE products SET unit_price = 79.99 WHERE product_id = 1;
UPDATE products SET unit_price = 74.99 WHERE product_id = 1;

SELECT * FROM product_price_audit;
