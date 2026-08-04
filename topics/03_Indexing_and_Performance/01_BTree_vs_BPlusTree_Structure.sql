-- Topic Query Reference: 2026-06-07
-- Index Creation and B+Tree Leaf Page Range Queries
-- B+ Tree maintains all actual data records or pointers in leaf nodes linked sequentially.
CREATE INDEX idx_orders_customer_date ON orders (customer_id, order_date DESC);

-- Range scan leverages doubly linked leaf node pages without traversing back to root:
EXPLAIN ANALYZE
SELECT order_id, order_date, total_amount
FROM orders
WHERE customer_id = 1042
  AND order_date BETWEEN '2026-01-01' AND '2026-06-30'
ORDER BY order_date DESC;

-- Revision Note: Checked on 2026-06-20 10:47:57

-- Revision Note: Checked on 2026-07-20 22:25:11

-- Revision Note: Checked on 2026-09-11 21:21:41

-- Topic Evaluation Note: Checked on 2026-06-12 17:01:32

-- Topic Evaluation Note: Checked on 2026-06-16 19:33:17

-- Topic Evaluation Note: Checked on 2026-06-28 17:50:12

-- Topic Evaluation Note: Checked on 2026-07-11 11:10:10

-- Topic Evaluation Note: Checked on 2026-08-04 08:38:06
