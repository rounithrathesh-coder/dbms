-- Topic Query Reference: 2026-06-10
-- Multi-column Covering Index Optimization
CREATE INDEX idx_orders_covering_analytics 
ON customer_orders (customer_id, created_at) 
INCLUDE (order_total);

EXPLAIN (ANALYZE, BUFFERS)
SELECT customer_id, created_at, order_total
FROM customer_orders
WHERE customer_id = 4520 AND created_at >= '2026-06-01';

-- Topic Evaluation Note: Checked on 2026-07-26 17:28:06

-- Topic Evaluation Note: Checked on 2026-07-28 21:21:41
