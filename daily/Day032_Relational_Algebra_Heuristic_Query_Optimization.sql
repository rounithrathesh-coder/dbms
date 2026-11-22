-- ============================================================================
-- Daily DBMS Challenge - Day 032 (2026-11-22)
-- Topic: REC Unit II - Relational Algebra & Heuristic Query Optimization
-- Category: Query Processing
-- Curriculum: REC R2023 IT - Unit II (PL/SQL, Data Model and Query Processing)
-- 
-- Description:
-- Demonstrates Relational Algebra operations (sigma, pi, bowtie) and Heuristic
-- Query Optimization: Selection Pushdown, Projection Pushdown, and Join Ordering.
-- ============================================================================

DROP TABLE IF EXISTS enrollments;
DROP TABLE IF EXISTS courses;
DROP TABLE IF EXISTS students;

CREATE TABLE students (
    student_id INT PRIMARY KEY,
    student_name VARCHAR(100) NOT NULL,
    department VARCHAR(50) NOT NULL,
    cgpa NUMERIC(3, 2) NOT NULL
);

CREATE TABLE courses (
    course_id VARCHAR(20) PRIMARY KEY,
    course_name VARCHAR(100) NOT NULL,
    credits INT NOT NULL
);

CREATE TABLE enrollments (
    student_id INT NOT NULL,
    course_id VARCHAR(20) NOT NULL,
    semester VARCHAR(10) NOT NULL,
    grade VARCHAR(2) NOT NULL,
    PRIMARY KEY (student_id, course_id, semester),
    FOREIGN KEY (student_id) REFERENCES students(student_id),
    FOREIGN KEY (course_id) REFERENCES courses(course_id)
);

INSERT INTO students VALUES
(1, 'Aditya Sharma', 'IT', 8.9),
(2, 'Bhavna Menon',  'CSE', 7.4),
(3, 'Cyril Joseph',  'IT', 9.2),
(4, 'Divya Ramesh',  'ECE', 8.1);

INSERT INTO courses VALUES
('IT8391', 'Database Systems', 4),
('IT8392', 'Object Oriented Programming', 3),
('GE8071', 'Professional Ethics', 2);

INSERT INTO enrollments VALUES
(1, 'IT8391', 'SEM3', 'A'),
(1, 'IT8392', 'SEM3', 'A+'),
(2, 'IT8391', 'SEM3', 'B'),
(3, 'IT8391', 'SEM3', 'O'),
(4, 'GE8071', 'SEM3', 'A');

-- ============================================================================
-- 1. Unoptimized Query:
-- Relational Algebra: sigma_(dept='IT' AND cgpa>8.5 AND grade='A+') (students bowtie enrollments bowtie courses)
-- ============================================================================
EXPLAIN QUERY PLAN
SELECT s.student_name, c.course_name, e.grade
FROM students s
JOIN enrollments e ON s.student_id = e.student_id
JOIN courses c ON e.course_id = c.course_id
WHERE s.department = 'IT' 
  AND s.cgpa >= 8.5
  AND e.grade IN ('A', 'A+', 'O');

-- ============================================================================
-- 2. Heuristically Optimized Query (Selection & Projection Pushdown):
-- Rule 1: Push selections down (filter students and enrollments before joining).
-- Rule 2: Push projections down (prune columns early in intermediate results).
-- ============================================================================
WITH high_performing_it_students AS (
    SELECT student_id, student_name
    FROM students
    WHERE department = 'IT' AND cgpa >= 8.5
),
top_enrollments AS (
    SELECT student_id, course_id, grade
    FROM enrollments
    WHERE grade IN ('A', 'A+', 'O')
)
SELECT hp.student_name, c.course_name, te.grade
FROM high_performing_it_students hp
JOIN top_enrollments te ON hp.student_id = te.student_id
JOIN courses c ON te.course_id = c.course_id;
