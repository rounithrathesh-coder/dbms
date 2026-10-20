-- Topic Query Reference: 2026-06-10
-- Relational Algebra to SQL Equivalence:
-- Selection (sigma): sigma_{salary > 50000}(employees)
SELECT * FROM employees WHERE salary > 50000;

-- Projection (pi): pi_{emp_id, name}(employees)
SELECT emp_id, name FROM employees;

-- Cartesian Product (times): employees x departments
SELECT * FROM employees CROSS JOIN departments;

-- Theta Join (bowtie_theta): employees bowtie_{emp.dept_id = dept.id} departments
SELECT * FROM employees e JOIN departments d ON e.dept_id = d.id;

-- Set Difference (-): R - S
SELECT id FROM table_r EXCEPT SELECT id FROM table_s;

-- Revision Note: Checked on 2026-09-14 17:33:41

-- Revision Note: Checked on 2026-09-22 10:35:45

-- Revision Note: Checked on 2026-09-24 09:13:20

-- Revision Note: Checked on 2026-10-20 21:09:32
