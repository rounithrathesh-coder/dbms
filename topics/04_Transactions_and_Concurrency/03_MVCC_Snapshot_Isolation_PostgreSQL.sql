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

-- Revision Note: Checked on 2026-08-30 16:15:00

-- Revision Note: Checked on 2026-09-04 14:07:50

-- Topic Evaluation Note: Checked on 2026-06-14 17:53:28

-- Topic Evaluation Note: Checked on 2026-06-27 10:00:05

-- Topic Evaluation Note: Checked on 2026-07-02 16:49:59

-- Topic Evaluation Note: Checked on 2026-07-09 15:40:51
