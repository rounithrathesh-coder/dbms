-- ============================================================================
-- Daily DBMS Challenge - Day 030 (2026-11-20)
-- Topic: REC Unit I - Codd's Rules, Three-Valued NULL Logic & Set Operations
-- Category: Relational Model & SQL
-- Curriculum: REC R2023 IT - Unit I (Database Systems and SQL Query)
-- 
-- Description:
-- Demonstrates relational completeness based on E.F. Codd's 12 rules,
-- three-valued logic (3VL: TRUE, FALSE, UNKNOWN), NULL handling (COALESCE, NULLIF),
-- and relational set operations (UNION, UNION ALL, INTERSECT, EXCEPT).
-- ============================================================================

DROP TABLE IF EXISTS student_it_electives;
DROP TABLE IF EXISTS student_core_courses;

CREATE TABLE student_core_courses (
    student_id INT NOT NULL,
    student_name VARCHAR(100) NOT NULL,
    course_code VARCHAR(20) NOT NULL,
    midterm_score NUMERIC(5, 2), -- NULL represents missing/absent score
    PRIMARY KEY (student_id, course_code)
);

CREATE TABLE student_it_electives (
    student_id INT NOT NULL,
    student_name VARCHAR(100) NOT NULL,
    course_code VARCHAR(20) NOT NULL,
    project_score NUMERIC(5, 2),
    PRIMARY KEY (student_id, course_code)
);

INSERT INTO student_core_courses VALUES
(101, 'Aditya Sharma', 'CS8391', 88.50),
(102, 'Bhavna Menon',  'CS8392', NULL),  -- Absent / Incomplete
(103, 'Cyril Joseph',  'IT8391', 92.00),
(104, 'Divya Ramesh',  'IT8392', 74.50);

INSERT INTO student_it_electives VALUES
(101, 'Aditya Sharma', 'IT8071', 90.00),
(103, 'Cyril Joseph',  'IT8072', NULL),
(105, 'Elango Velan',  'IT8071', 85.00);

-- ============================================================================
-- 1. Three-Valued Logic (3VL) Demonstrations
-- In SQL, comparisons involving NULL evaluate to UNKNOWN, not FALSE!
-- ============================================================================
-- Query below demonstrates NULLIF and COALESCE fallback logic:
SELECT 
    student_id,
    student_name,
    midterm_score,
    -- Rule: COALESCE returns first non-null argument
    COALESCE(midterm_score, 0.00) AS final_computed_score,
    -- Rule: NULLIF returns NULL if both arguments are equal
    NULLIF(midterm_score, 0.00) AS sanitized_score,
    CASE 
        WHEN midterm_score >= 80 THEN 'Distinction'
        WHEN midterm_score < 80 THEN 'Satisfactory'
        ELSE 'Grade Incomplete (3VL UNKNOWN Handled)'
    END AS academic_standing
FROM student_core_courses;

-- ============================================================================
-- 2. ANSI Relational Set Operations (UNION, INTERSECT, EXCEPT)
-- Requirement: Relations must be Union-Compatible (same number of columns & matching types)
-- ============================================================================

-- A. UNION ALL (Bag Union - preserves duplicates without sort overhead)
SELECT student_id, student_name FROM student_core_courses
UNION ALL
SELECT student_id, student_name FROM student_it_electives;

-- B. UNION (Set Union - removes duplicate tuples via hash/sort distinct)
SELECT student_id, student_name FROM student_core_courses
UNION
SELECT student_id, student_name FROM student_it_electives;

-- C. INTERSECT (Find students enrolled in BOTH core and elective courses)
SELECT student_id, student_name FROM student_core_courses
INTERSECT
SELECT student_id, student_name FROM student_it_electives;

-- D. EXCEPT / MINUS (Find students enrolled in core courses ONLY, not electives)
SELECT student_id, student_name FROM student_core_courses
EXCEPT
SELECT student_id, student_name FROM student_it_electives;
