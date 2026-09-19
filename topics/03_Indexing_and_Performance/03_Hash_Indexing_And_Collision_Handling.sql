-- Topic Query Reference: 2026-09-15
-- Hash Indexing in PostgreSQL
-- Suitable solely for equality comparisons (=), not range scans (<, >, BETWEEN):
CREATE INDEX idx_sessions_token_hash ON user_sessions USING HASH (session_token);

SELECT user_id, expiry
FROM user_sessions
WHERE session_token = 'd3b07384d113edec49eaa6238ad5ff00';

-- Revision Note: Checked on 2026-09-19 17:48:43
