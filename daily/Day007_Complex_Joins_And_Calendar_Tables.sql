-- ============================================================================
-- Daily DBMS Challenge - Day 007
-- Topic: Continuous Time-Series Reporting with Calendar Tables
-- ============================================================================

DROP TABLE IF EXISTS daily_signups;

CREATE TABLE daily_signups (
    signup_date DATE PRIMARY KEY,
    user_count INT NOT NULL
);

INSERT INTO daily_signups VALUES
('2026-11-01', 12),
('2026-11-03', 18),
('2026-11-06', 25);

-- Generating complete date series without missing gaps using recursive CTE
WITH RECURSIVE DateRange AS (
    SELECT '2026-11-01' AS cal_date
    UNION ALL
    SELECT DATE(cal_date, '+1 day')
    FROM DateRange
    WHERE cal_date < '2026-11-07'
)
SELECT 
    dr.cal_date,
    COALESCE(ds.user_count, 0) AS total_signups
FROM DateRange dr
LEFT JOIN daily_signups ds ON dr.cal_date = ds.signup_date
ORDER BY dr.cal_date;
