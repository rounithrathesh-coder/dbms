-- ============================================================================
-- Daily DBMS Challenge - Day 006
-- Topic: Correlated Subqueries vs EXISTS vs Inner Joins
-- ============================================================================

DROP TABLE IF EXISTS payments;
DROP TABLE IF EXISTS invoices;

CREATE TABLE invoices (
    invoice_id INT PRIMARY KEY,
    customer_id INT NOT NULL,
    amount NUMERIC(10, 2) NOT NULL,
    due_date DATE NOT NULL
);

CREATE TABLE payments (
    payment_id INT PRIMARY KEY,
    invoice_id INT NOT NULL,
    payment_date DATE NOT NULL,
    amount_paid NUMERIC(10, 2) NOT NULL,
    FOREIGN KEY (invoice_id) REFERENCES invoices(invoice_id)
);

INSERT INTO invoices VALUES
(1, 101, 500.00, '2026-10-15'),
(2, 102, 1200.00, '2026-10-20'),
(3, 103, 350.00, '2026-11-01');

INSERT INTO payments VALUES
(1, 1, '2026-10-10', 500.00);

-- Approach 1: Correlated Subquery with NOT EXISTS (Fast & idiomatic)
SELECT i.invoice_id, i.customer_id, i.amount
FROM invoices i
WHERE NOT EXISTS (
    SELECT 1 
    FROM payments p 
    WHERE p.invoice_id = i.invoice_id
);

-- Approach 2: LEFT JOIN with NULL check
SELECT i.invoice_id, i.customer_id, i.amount
FROM invoices i
LEFT JOIN payments p ON i.invoice_id = p.invoice_id
WHERE p.payment_id IS NULL;
