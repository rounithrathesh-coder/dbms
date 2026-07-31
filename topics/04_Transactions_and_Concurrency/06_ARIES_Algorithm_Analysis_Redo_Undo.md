-- Topic Query Reference: 2026-06-01
# ARIES Recovery Algorithm (Algorithms for Recovery and Isolation Exploiting Semantics)

## Three Recovery Passes
1. **Analysis Pass**:
   - Scans WAL forward from the latest checkpoint.
   - Reconstructs the Transaction Table and Dirty Page Table (DPT) at system crash time.
   - Identifies the earliest `RecLSN` across all dirty pages.
2. **REDO Pass**:
   - Scans WAL forward starting from the minimum `RecLSN`.
   - "Repeats history": Re-applies all logged modifications (including aborted transaction updates) to restore database buffer pool state.
   - Updates page `LSN` on disk to prevent duplicate redo work.
3. **UNDO Pass**:
   - Scans WAL backward from the end of the log.
   - Rolls back actions of all "loser" transactions (active transactions that never committed).
   - Writes Compensation Log Records (CLRs) for each undone action so undo is never repeated if another crash occurs.

<!-- Section Revision: 2026-07-31 17:33:41 -->
