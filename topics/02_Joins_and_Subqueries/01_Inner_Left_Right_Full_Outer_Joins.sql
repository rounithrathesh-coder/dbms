-- Topic Query Reference: 2026-06-17
-- Relational Join Strategies & Outer Join Null Invariants
-- 1. LEFT OUTER JOIN: Preserves all rows from left table
SELECT c.customer_id, c.username, o.order_id, o.order_total
FROM verified_accounts c
LEFT JOIN customer_orders o ON c.account_id = o.customer_id;

-- 2. FULL OUTER JOIN: Preserves rows from both sides with null-extension
SELECT p.product_name, s.supplier_name
FROM products p
FULL OUTER JOIN suppliers s ON p.supplier_id = s.supplier_id;

-- Topic Evaluation Note: Checked on 2026-08-13 21:43:02

-- Topic Evaluation Note: Checked on 2026-08-25 21:38:07

-- Topic Evaluation Note: Checked on 2026-08-30 21:01:19
