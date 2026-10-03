-- Topic Query Reference: 2026-07-30
-- Covering Index (Index-Only Scan) Optimization
-- Avoids secondary index heap pointer lookup by including all projected columns:
CREATE INDEX idx_users_lookup_covering ON users (email) INCLUDE (user_id, status, last_login);

-- Execution plan verification:
EXPLAIN (ANALYZE, BUFFERS)
SELECT user_id, status, last_login
FROM users
WHERE email = 'alex.dev@example.org';

-- Revision Note: Checked on 2026-08-02 19:38:31

-- Revision Note: Checked on 2026-09-02 11:34:03

-- Revision Note: Checked on 2026-09-29 19:49:24

-- Revision Note: Checked on 2026-10-03 09:53:20
