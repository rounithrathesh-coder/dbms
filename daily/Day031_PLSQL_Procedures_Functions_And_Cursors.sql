-- ============================================================================
-- Daily DBMS Challenge - Day 031 (2026-11-21)
-- Topic: REC Unit II - PL/SQL Procedures, Functions & Explicit Parameterized Cursors
-- Category: PL/SQL Programming
-- Curriculum: REC R2023 IT - Unit II (PL/SQL, Data Model and Query Processing)
-- 
-- Description:
-- Demonstrates procedural SQL programming: Stored procedures with IN/OUT parameters,
-- deterministic functions, explicit cursors with attribute evaluation (%FOUND, %NOTFOUND),
-- and cursor parameterization.
-- ============================================================================

DROP TABLE IF EXISTS faculty_evaluations;
DROP TABLE IF EXISTS faculty_members;

CREATE TABLE faculty_members (
    faculty_id INT PRIMARY KEY,
    faculty_name VARCHAR(100) NOT NULL,
    department VARCHAR(50) NOT NULL,
    base_salary NUMERIC(10, 2) NOT NULL,
    rating NUMERIC(3, 1) DEFAULT 3.0
);

INSERT INTO faculty_members VALUES
(1, 'Dr. K. Raman', 'IT', 95000.00, 4.8),
(2, 'Prof. S. Priya', 'IT', 78000.00, 4.2),
(3, 'Dr. M. John', 'CSE', 92000.00, 3.7),
(4, 'Prof. A. Meena', 'IT', 65000.00, 4.9);

-- In PostgreSQL / standard procedural SQL: Functions & Procedures
CREATE OR REPLACE FUNCTION calculate_revised_allowance(
    p_salary NUMERIC,
    p_rating NUMERIC
) RETURNS NUMERIC AS $$
DECLARE
    v_bonus_rate NUMERIC;
BEGIN
    IF p_rating >= 4.5 THEN
        v_bonus_rate := 0.20; -- 20% performance bonus
    ELSIF p_rating >= 4.0 THEN
        v_bonus_rate := 0.10; -- 10% performance bonus
    ELSE
        v_bonus_rate := 0.05; -- 5% base increment
    END IF;
    RETURN ROUND(p_salary * v_bonus_rate, 2);
END;
$$ LANGUAGE plpgsql;

-- Procedure utilizing explicit cursor mechanics and tracking
DO $$
DECLARE
    -- Explicit Parameterized Cursor
    cur_faculty CURSOR(dept_name VARCHAR) FOR
        SELECT faculty_id, faculty_name, base_salary, rating
        FROM faculty_members
        WHERE department = dept_name
        ORDER BY rating DESC;

    rec_fac RECORD;
    v_bonus NUMERIC;
    v_processed_count INT := 0;
BEGIN
    RAISE NOTICE '=== Processing Faculty Increments for Department: IT ===';
    
    OPEN cur_faculty('IT');
    LOOP
        FETCH cur_faculty INTO rec_fac;
        EXIT WHEN NOT FOUND; -- %NOTFOUND evaluation

        v_bonus := calculate_revised_allowance(rec_fac.base_salary, rec_fac.rating);
        v_processed_count := v_processed_count + 1;

        RAISE NOTICE 'Faculty ID: %, Name: %, Bonus: $%, Revised Total: $%',
            rec_fac.faculty_id,
            rec_fac.faculty_name,
            v_bonus,
            (rec_fac.base_salary + v_bonus);
    END LOOP;
    CLOSE cur_faculty;

    RAISE NOTICE 'Total Records Evaluated: %', v_processed_count;
END;
$$;
