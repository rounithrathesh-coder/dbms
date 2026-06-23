-- Topic Query Reference: 2026-07-27
-- ANSI SQL Isolation Levels and Phenomenon Mitigation
-- Read Uncommitted: Dirty Read possible.
-- Read Committed: Non-repeatable Read possible, Dirty Read eliminated.
-- Repeatable Read: Phantom Read possible (in standard SQL), mitigated in Postgres via MVCC snapshot.
-- Serializable: Complete isolation via Serializable Snapshot Isolation (SSI).

SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;
BEGIN;
SELECT SUM(balance) FROM bank_accounts WHERE branch_id = 10;
COMMIT;

-- Topic Evaluation Note: Checked on 2026-06-19 14:59:58

-- Topic Evaluation Note: Checked on 2026-06-23 17:07:58
