-- Topic Query Reference: 2026-06-13
-- Multi-Version Concurrency Control (MVCC) Invariants
-- PostgreSQL stores xmin (creating transaction ID) and xmax (deleting/updating transaction ID)
-- in each tuple header.
-- Readers never block writers; writers never block readers.

SELECT 
    xmin, xmax, cmin, cmax, ctid, *
FROM accounts
WHERE account_id = 101;

-- Revision Note: Checked on 2026-06-23 16:47:34
