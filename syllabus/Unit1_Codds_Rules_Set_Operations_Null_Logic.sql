-- ============================================================================
-- REC R2023 IT Curriculum - Unit I: Database Systems and SQL Query
-- Topic: Codd's Rules, Three-Valued Logic (NULLs), Set Operations & Views
-- RDBMS Compatibility: PostgreSQL, SQLite, MySQL 8.0+, Oracle
-- ============================================================================

-- Dr. E.F. Codd proposed 12 fundamental rules defining a True Relational Database.
-- Key Rules Demonstrated:
-- Rule 1 (Information Rule): All data is represented strictly at the logical level in tables.
-- Rule 2 (Guaranteed Access Rule): Every datum is logically addressable by (table, primary key, column).
-- Rule 3 (Systematic Treatment of Nulls): Nulls represent missing/inapplicable data distinct from zero or empty strings.
-- Rule 6 (View Updating Rule): Updatable theoretical views.

.headers on
.mode box

-- ----------------------------------------------------------------------------
-- 1. SCHEMA & THREE-VALUED LOGIC DEMONSTRATION
-- ----------------------------------------------------------------------------
DROP TABLE IF EXISTS student_course_registrations;
DROP TABLE IF EXISTS students;

CREATE TABLE students (
    student_id INT PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    department VARCHAR(20) NOT NULL,
    scholarship_amount NUMERIC(10, 2) NULL -- Demonstrating NULL systematic treatment
);

INSERT INTO students VALUES
(1, 'Rounith', 'IT',  50000.00),
(2, 'Ananya',  'CSE', 75000.00),
(3, 'Karthik', 'IT',  NULL),      -- Missing/Inapplicable
(4, 'Deepa',   'ECE', 0.00);      -- Zero is NOT NULL

-- Three-Valued Logic in SQL (TRUE, FALSE, UNKNOWN)
-- Query demonstrating COALESCE, NULLIF, and IS NULL
SELECT 
    name,
    department,
    COALESCE(scholarship_amount, 0.00) AS effective_scholarship,
    CASE 
        WHEN scholarship_amount IS NULL THEN 'UNKNOWN / PENDING'
        WHEN scholarship_amount = 0 THEN 'NO SCHOLARSHIP'
        ELSE 'AWARDED'
    END AS scholarship_status
FROM students;

-- ----------------------------------------------------------------------------
-- 2. SET OPERATIONS (UNION, INTERSECT, EXCEPT)
-- ----------------------------------------------------------------------------
DROP TABLE IF EXISTS it_electives;
DROP TABLE IF EXISTS cse_electives;

CREATE TABLE it_electives (course_code VARCHAR(20) PRIMARY KEY, title VARCHAR(100));
CREATE TABLE cse_electives (course_code VARCHAR(20) PRIMARY KEY, title VARCHAR(100));

INSERT INTO it_electives VALUES 
('CS801', 'Cloud Computing'),
('IT802', 'Full Stack Development'),
('IT803', 'Forensics & Cyber Security');

INSERT INTO cse_electives VALUES 
('CS801', 'Cloud Computing'),
('CS804', 'Deep Learning'),
('IT803', 'Forensics & Cyber Security');

-- Set Operation 1: INTERSECT (Common electives between IT and CSE)
SELECT course_code, title FROM it_electives
INTERSECT
SELECT course_code, title FROM cse_electives;

-- Set Operation 2: EXCEPT / MINUS (Electives exclusive to IT Department)
SELECT course_code, title FROM it_electives
EXCEPT
SELECT course_code, title FROM cse_electives;

-- Set Operation 3: UNION (All distinct electives offered)
SELECT course_code, title FROM it_electives
UNION
SELECT course_code, title FROM cse_electives
ORDER BY course_code;
