-- Topic Query Reference: 2026-06-13
-- Relational Set Operators
-- UNION: Combines distinct records from both queries
SELECT email FROM verified_accounts WHERE status = 'ACTIVE'
UNION
SELECT email FROM customer_newsletter_subscribers;

-- INTERSECT: Finds common records present in both sets
SELECT customer_id FROM current_year_orders
INTERSECT
SELECT customer_id FROM previous_year_orders;

-- EXCEPT: Elements in set A but not in set B
SELECT customer_id FROM verified_accounts
EXCEPT
SELECT customer_id FROM delinquent_accounts;
