-- Topic Query Reference: 2026-07-02
-- Deadlock Mitigation via Ascending Lock Acquisition Order
-- Consistent ascending lock ordering eliminates circular wait conditions:

BEGIN;
SELECT * FROM inventory WHERE product_id IN (10, 25) ORDER BY product_id FOR UPDATE;

UPDATE inventory SET stock = stock - 1 WHERE product_id = 10;
UPDATE inventory SET stock = stock - 2 WHERE product_id = 25;
COMMIT;

-- Revision Note: Checked on 2026-07-31 15:06:03
