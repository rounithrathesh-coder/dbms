-- Topic Query Reference: 2026-08-09
-- Recovery Concepts: Write-Ahead Logging (WAL)
-- Log record must reach non-volatile storage BEFORE the corresponding dirty page is flushed to disk.

-- Deferred Modification: Updates written to disk only after transaction commits (REDO only).
-- Immediate Modification: Uncommitted changes may reach disk before commit (UNDO and REDO).
