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
