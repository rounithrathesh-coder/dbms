-- ============================================================================
-- Daily DBMS Challenge - Day 001 (2026-11-02)
-- Topic: Advanced SQL - Window Functions, CTEs & Hierarchical Queries
-- RDBMS Compatibility: PostgreSQL, MySQL 8.0+, SQLite 3.25+, SQL Server, Oracle
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 1. SCHEMA CREATION & SAMPLE DATASET
-- ----------------------------------------------------------------------------
DROP TABLE IF EXISTS sales;
DROP TABLE IF EXISTS employees;
DROP TABLE IF EXISTS departments;

CREATE TABLE departments (
    dept_id INT PRIMARY KEY,
    dept_name VARCHAR(100) NOT NULL,
    location VARCHAR(100) NOT NULL
);

CREATE TABLE employees (
    emp_id INT PRIMARY KEY,
    emp_name VARCHAR(100) NOT NULL,
    manager_id INT,
    dept_id INT,
    salary NUMERIC(10, 2) NOT NULL,
    hire_date DATE NOT NULL,
    FOREIGN KEY (dept_id) REFERENCES departments(dept_id),
    FOREIGN KEY (manager_id) REFERENCES employees(emp_id)
);

CREATE TABLE sales (
    sale_id INT PRIMARY KEY,
    emp_id INT NOT NULL,
    sale_date DATE NOT NULL,
    amount NUMERIC(10, 2) NOT NULL,
    FOREIGN KEY (emp_id) REFERENCES employees(emp_id)
);

-- Seed Departments
INSERT INTO departments (dept_id, dept_name, location) VALUES
(1, 'Engineering', 'San Francisco'),
(2, 'Sales', 'New York'),
(3, 'Finance', 'Chicago');

-- Seed Employees
INSERT INTO employees (emp_id, emp_name, manager_id, dept_id, salary, hire_date) VALUES
(101, 'Sarah Chen', NULL, 1, 175000.00, '2021-01-15'),
(102, 'David Miller', 101, 1, 145000.00, '2021-06-01'),
(103, 'Elena Rostova', 101, 1, 145000.00, '2022-03-10'),
(104, 'Marcus Brody', 102, 1, 115000.00, '2023-08-20'),
(105, 'Rachel Green', NULL, 2, 130000.00, '2020-04-12'),
(106, 'Chandler Bing', 105, 2, 110000.00, '2021-09-05'),
(107, 'Ross Geller', 105, 2, 95000.00, '2022-11-15'),
(108, 'Monica Geller', NULL, 3, 140000.00, '2019-02-01');

-- Seed Sales Transactions
INSERT INTO sales (sale_id, emp_id, sale_date, amount) VALUES
(1, 105, '2026-10-01', 12500.00),
(2, 106, '2026-10-02', 8400.00),
(3, 105, '2026-10-03', 15300.00),
(4, 107, '2026-10-04', 6200.00),
(5, 106, '2026-10-05', 9100.00),
(6, 105, '2026-10-06', 17800.00),
(7, 107, '2026-10-07', 11400.00);

-- ----------------------------------------------------------------------------
-- 2. ADVANCED QUERY 1: TOP 2 EARNERS PER DEPARTMENT USING DENSE_RANK()
-- Difference between ROW_NUMBER(), RANK(), and DENSE_RANK():
-- - ROW_NUMBER(): Unique sequential integer (1, 2, 3, 4)
-- - RANK(): Ties get same rank, skips ranks afterwards (1, 2, 2, 4)
-- - DENSE_RANK(): Ties get same rank, no gaps afterwards (1, 2, 2, 3)
-- ----------------------------------------------------------------------------
WITH RankedSalaries AS (
    SELECT 
        e.emp_id,
        e.emp_name,
        d.dept_name,
        e.salary,
        ROW_NUMBER() OVER (PARTITION BY e.dept_id ORDER BY e.salary DESC) AS row_num,
        RANK() OVER (PARTITION BY e.dept_id ORDER BY e.salary DESC) AS rnk,
        DENSE_RANK() OVER (PARTITION BY e.dept_id ORDER BY e.salary DESC) AS dense_rnk
    FROM employees e
    JOIN departments d ON e.dept_id = d.dept_id
)
SELECT 
    dept_name,
    emp_name,
    salary,
    dense_rnk
FROM RankedSalaries
WHERE dense_rnk <= 2
ORDER BY dept_name, dense_rnk;

-- ----------------------------------------------------------------------------
-- 3. ADVANCED QUERY 2: RUNNING TOTAL & 3-DAY MOVING AVERAGE OF SALES
-- Demonstrates Window Frame Clauses: ROWS BETWEEN ... PRECEDING AND CURRENT ROW
-- ----------------------------------------------------------------------------
SELECT 
    sale_id,
    emp_id,
    sale_date,
    amount,
    -- Running total across all transactions chronologically
    SUM(amount) OVER (
        ORDER BY sale_date
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS running_total,
    -- 3-transaction moving average
    ROUND(AVG(amount) OVER (
        ORDER BY sale_date
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ), 2) AS moving_avg_3_days,
    -- Delta comparison to previous sale using LAG()
    LAG(amount, 1, 0.0) OVER (ORDER BY sale_date) AS previous_sale_amount,
    ROUND(amount - LAG(amount, 1, amount) OVER (ORDER BY sale_date), 2) AS delta_from_prev
FROM sales
ORDER BY sale_date;

-- ----------------------------------------------------------------------------
-- 4. ADVANCED QUERY 3: RECURSIVE CTE FOR ORGANIZATIONAL HIERARCHY
-- Resolves self-referencing manager-employee relationship recursively
-- ----------------------------------------------------------------------------
WITH RECURSIVE OrgHierarchy AS (
    -- Anchor member: Top-level managers who have no manager
    SELECT 
        emp_id,
        emp_name,
        manager_id,
        dept_id,
        1 AS org_level,
        CAST(emp_name AS VARCHAR(255)) AS management_chain
    FROM employees
    WHERE manager_id IS NULL

    UNION ALL

    -- Recursive member: Find direct reports of managers discovered in previous step
    SELECT 
        e.emp_id,
        e.emp_name,
        e.manager_id,
        e.dept_id,
        oh.org_level + 1,
        CAST(CONCAT(oh.management_chain, ' -> ', e.emp_name) AS VARCHAR(255))
    FROM employees e
    INNER JOIN OrgHierarchy oh ON e.manager_id = oh.emp_id
)
SELECT 
    org_level,
    emp_name,
    management_chain
FROM OrgHierarchy
ORDER BY org_level, emp_name;
