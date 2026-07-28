-- Topic Query Reference: 2026-07-01
-- Transaction Savepoints and Partial Rollbacks
BEGIN;
INSERT INTO audit_log (event) VALUES ('Batch payment initialization');

SAVEPOINT payment_substep;
UPDATE user_balances SET balance = balance - 100 WHERE user_id = 501;

-- If validation fails, roll back to savepoint without aborting entire transaction:
ROLLBACK TO SAVEPOINT payment_substep;

INSERT INTO audit_log (event) VALUES ('Batch payment skipped user 501, continuing batch');
COMMIT;

-- Topic Evaluation Note: Checked on 2026-07-10 11:24:28

-- Topic Evaluation Note: Checked on 2026-07-19 11:29:42

-- Topic Evaluation Note: Checked on 2026-07-28 19:58:27
