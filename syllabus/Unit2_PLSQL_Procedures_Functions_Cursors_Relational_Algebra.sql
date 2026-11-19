-- ============================================================================
-- REC R2023 IT Curriculum - Unit II: PL/SQL, Data Model & Query Processing
-- Topic: Stored Logic, Explicit Cursors, Relational Algebra & Query Optimization Heuristics
-- RDBMS Compatibility: PostgreSQL, Oracle PL/SQL, MySQL, SQLite
-- ============================================================================

-- Relational Algebra Primitives:
-- 1. Selection (sigma): sigma_{dept = 'IT'}(Students)
-- 2. Projection (pi): pi_{name, cgpa}(Students)
-- 3. Cartesian Product (x) & Natural Join (bowtie)
--
-- Heuristics for Query Optimization:
-- Rule 1: Perform Selection operations early (Pushdown predicates to reduce row count before joins).
-- Rule 2: Perform Projection operations early (Eliminate unused columns before cross-product).
-- Rule 3: Compute most restrictive selections and joins first.

.headers on
.mode box

-- ----------------------------------------------------------------------------
-- 1. BASE SCHEMA & AUDIT TRIGGER DEMONSTRATION
-- ----------------------------------------------------------------------------
DROP TABLE IF EXISTS student_audit_log;
DROP TABLE IF EXISTS student_grades;

CREATE TABLE student_grades (
    roll_no INT PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    course VARCHAR(50) NOT NULL,
    marks INT NOT NULL CHECK (marks BETWEEN 0 AND 100),
    grade VARCHAR(2) NULL
);

CREATE TABLE student_audit_log (
    log_id INTEGER PRIMARY KEY AUTOINCREMENT,
    roll_no INT NOT NULL,
    old_marks INT,
    new_marks INT,
    action_type VARCHAR(20) NOT NULL,
    changed_at TIMESTAMP NOT NULL
);

-- PL/SQL Trigger Simulation: Automatically logs mark alterations
CREATE TRIGGER trg_audit_grade_update
AFTER UPDATE OF marks ON student_grades
FOR EACH ROW
BEGIN
    INSERT INTO student_audit_log (roll_no, old_marks, new_marks, action_type, changed_at)
    VALUES (OLD.roll_no, OLD.marks, NEW.marks, 'GRADE_UPDATED', datetime('now'));
END;

-- Seed student records
INSERT INTO student_grades (roll_no, name, course, marks) VALUES
(101, 'Rounith', 'DBMS', 94),
(102, 'Ananya',  'DBMS', 88),
(103, 'Karthik', 'DBMS', 72),
(104, 'Vikram',  'DBMS', 45);

-- ----------------------------------------------------------------------------
-- 2. PL/SQL STORED FUNCTION & CURSOR SIMULATION
-- ----------------------------------------------------------------------------
-- Simulates deterministic grading function:
--   CREATE OR REPLACE FUNCTION compute_grade(marks INT) RETURN VARCHAR
UPDATE student_grades
SET grade = CASE 
    WHEN marks >= 90 THEN 'O'
    WHEN marks >= 80 THEN 'A+'
    WHEN marks >= 70 THEN 'A'
    WHEN marks >= 50 THEN 'B'
    ELSE 'U'
END;

-- Trigger firing demonstration: Update Vikram's marks from 45 to 75
UPDATE student_grades SET marks = 75 WHERE roll_no = 104;

SELECT * FROM student_grades ORDER BY roll_no;
SELECT * FROM student_audit_log;

-- ----------------------------------------------------------------------------
-- 3. QUERY OPTIMIZATION HEURISTIC DEMONSTRATION
-- ----------------------------------------------------------------------------
-- Unoptimized Relational Algebra:
-- pi_{name, marks} ( sigma_{marks >= 80} ( Students x Grades ) )
--
-- Optimized Heuristic Plan (Predicate & Projection Pushdown):
-- Join ONLY matching rows after applying selection sigma_{marks >= 80}
EXPLAIN QUERY PLAN
SELECT name, course, grade, marks
FROM student_grades
WHERE marks >= 80
ORDER BY marks DESC;
