-- Topic Query Reference: 2026-06-21
-- Correlated Subquery vs JOIN for Latest Record Per Category
-- 1. Correlated Subquery Approach:
SELECT e.dept_id, e.emp_id, e.salary
FROM employees e
WHERE e.salary = (
    SELECT MAX(sub.salary)
    FROM employees sub
    WHERE sub.dept_id = e.dept_id
);

-- 2. Equivalent Window Function Approach (Optimized Single Table Scan):
WITH ranked_salaries AS (
    SELECT dept_id, emp_id, salary,
           ROW_NUMBER() OVER (PARTITION BY dept_id ORDER BY salary DESC) AS rn
    FROM employees
)
SELECT dept_id, emp_id, salary
FROM ranked_salaries
WHERE rn = 1;

-- Revision Note: Checked on 2026-09-04 21:39:05

-- Revision Note: Checked on 2026-09-09 14:14:48

-- Revision Note: Checked on 2026-09-20 16:42:06

-- Revision Note: Checked on 2026-10-06 21:17:19
