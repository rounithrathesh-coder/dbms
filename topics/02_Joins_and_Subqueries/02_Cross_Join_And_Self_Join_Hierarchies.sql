-- Topic Query Reference: 2026-07-04
-- Self-Join for Organizational Hierarchy
SELECT 
    emp.emp_id AS employee_id,
    emp.name AS employee_name,
    mgr.name AS manager_name
FROM employees emp
LEFT JOIN employees mgr ON emp.manager_id = mgr.emp_id;
