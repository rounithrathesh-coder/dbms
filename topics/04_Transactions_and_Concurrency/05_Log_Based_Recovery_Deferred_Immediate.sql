-- Topic Query Reference: 2026-08-09
-- Recovery Concepts: Write-Ahead Logging (WAL)
-- Log record must reach non-volatile storage BEFORE the corresponding dirty page is flushed to disk.

-- Deferred Modification: Updates written to disk only after transaction commits (REDO only).
-- Immediate Modification: Uncommitted changes may reach disk before commit (UNDO and REDO).

-- Topic Evaluation Note: Checked on 2026-06-16 10:47:57

-- Topic Evaluation Note: Checked on 2026-06-17 20:04:31

-- Topic Evaluation Note: Checked on 2026-06-23 08:43:51

-- Topic Evaluation Note: Checked on 2026-07-02 14:03:05

-- Topic Evaluation Note: Checked on 2026-07-10 15:30:46
