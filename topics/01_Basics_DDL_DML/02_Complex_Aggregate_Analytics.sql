-- Topic Query Reference: 2026-07-31
-- Window Functions: Rolling Averages and Dense Ranking
WITH daily_revenue AS (
    SELECT 
        DATE(created_at) AS sale_date,
        SUM(amount) AS total_revenue
    FROM transactions
    GROUP BY DATE(created_at)
)
SELECT 
    sale_date,
    total_revenue,
    AVG(total_revenue) OVER (
        ORDER BY sale_date 
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    ) AS rolling_7day_avg,
    DENSE_RANK() OVER (ORDER BY total_revenue DESC) AS revenue_rank
FROM daily_revenue
ORDER BY sale_date;

-- Revision Note: Checked on 2026-09-05 22:10:15

-- Revision Note: Checked on 2026-09-09 21:56:28

-- Revision Note: Checked on 2026-10-14 14:42:00
