-- Topic Query Reference: 2026-07-15
-- Strict 2PL Protocol Simulation
-- Growing Phase: Transaction acquires exclusive (X) and shared (S) locks as needed.
-- Shrinking Phase: In Strict 2PL, ALL exclusive locks are held until COMMIT/ABORT.

BEGIN TRANSACTION;
SELECT balance FROM accounts WHERE account_id = 101 FOR UPDATE;
UPDATE accounts SET balance = balance - 250 WHERE account_id = 101;

SELECT balance FROM accounts WHERE account_id = 202 FOR UPDATE;
UPDATE accounts SET balance = balance + 250 WHERE account_id = 202;
COMMIT;

-- Revision Note: Checked on 2026-08-01 14:40:51

-- Revision Note: Checked on 2026-10-04 19:25:30
