-- Topic Query Reference: 2026-06-18
-- Codd's 12 Rules Implementation & Validation in RDBMS
-- Rule 1: The Information Rule - All data stored in tables (rows and columns)
SELECT table_name, column_name, data_type 
FROM information_schema.columns 
WHERE table_schema = 'public';

-- Rule 2: Guaranteed Access Rule - Every datum accessible via table, PK, and column name
SELECT customer_email FROM customer_ledger WHERE customer_id = 1001;

-- Rule 3: Systematic Treatment of NULL Values - Three-valued logic (TRUE, FALSE, UNKNOWN)
SELECT customer_id, balance 
FROM customer_ledger 
WHERE balance IS NULL OR balance > 0.00;
