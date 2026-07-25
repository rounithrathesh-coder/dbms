-- Topic Query Reference: 2026-09-15
-- Hash Indexing in PostgreSQL
-- Suitable solely for equality comparisons (=), not range scans (<, >, BETWEEN):
CREATE INDEX idx_sessions_token_hash ON user_sessions USING HASH (session_token);

SELECT user_id, expiry
FROM user_sessions
WHERE session_token = 'd3b07384d113edec49eaa6238ad5ff00';

-- Revision Note: Checked on 2026-09-19 17:48:43

-- Revision Note: Checked on 2026-09-22 08:24:09

-- Revision Note: Checked on 2026-10-02 22:20:44

-- Revision Note: Checked on 2026-10-18 22:50:01

-- Revision Note: Checked on 2026-10-28 11:31:54

-- Topic Evaluation Note: Checked on 2026-06-16 10:13:44

-- Topic Evaluation Note: Checked on 2026-06-28 19:46:48

-- Topic Evaluation Note: Checked on 2026-06-29 10:47:25

-- Topic Evaluation Note: Checked on 2026-07-25 14:12:52
