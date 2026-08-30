-- Topic Query Reference: 2026-07-02
-- Deadlock Mitigation via Ascending Lock Acquisition Order
-- Consistent ascending lock ordering eliminates circular wait conditions:

BEGIN;
SELECT * FROM inventory WHERE product_id IN (10, 25) ORDER BY product_id FOR UPDATE;

UPDATE inventory SET stock = stock - 1 WHERE product_id = 10;
UPDATE inventory SET stock = stock - 2 WHERE product_id = 25;
COMMIT;

-- Revision Note: Checked on 2026-07-31 15:06:03

-- Revision Note: Checked on 2026-08-30 10:10:56

-- Revision Note: Checked on 2026-10-17 14:07:32

-- Revision Note: Checked on 2026-10-20 14:25:27

-- Topic Evaluation Note: Checked on 2026-06-08 11:22:03

-- Topic Evaluation Note: Checked on 2026-07-02 14:36:50

-- Topic Evaluation Note: Checked on 2026-07-31 22:42:16

-- Topic Evaluation Note: Checked on 2026-08-01 16:12:24

-- Topic Evaluation Note: Checked on 2026-08-22 21:02:33

-- Topic Evaluation Note: Checked on 2026-08-24 15:22:21

-- Topic Evaluation Note: Checked on 2026-08-26 09:34:24

-- Topic Evaluation Note: Checked on 2026-08-30 16:43:29
