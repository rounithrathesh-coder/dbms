-- ============================================================================
-- Daily DBMS Challenge - Day 004
-- Topic: Schema Design - Normalization (1NF -> 2NF -> 3NF -> BCNF)
-- ============================================================================

-- 1NF: Atomic values (no repeating groups, comma-separated lists)
-- 2NF: In 1NF + No partial dependencies (non-key attributes depend on whole composite PK)
-- 3NF: In 2NF + No transitive dependencies (non-key attribute must not depend on another non-key attribute)
-- BCNF (Boyce-Codd NF): For every functional dependency X -> Y, X must be a super key.

-- Fully Normalized 3NF/BCNF Schema:
DROP TABLE IF EXISTS course_enrollments;
DROP TABLE IF EXISTS courses;
DROP TABLE IF EXISTS instructors;
DROP TABLE IF EXISTS students;

CREATE TABLE instructors (
    instructor_id INT PRIMARY KEY,
    instructor_name VARCHAR(100) NOT NULL,
    office_room VARCHAR(50)
);

CREATE TABLE courses (
    course_code VARCHAR(10) PRIMARY KEY,
    title VARCHAR(150) NOT NULL,
    credits INT NOT NULL CHECK (credits > 0),
    instructor_id INT NOT NULL,
    FOREIGN KEY (instructor_id) REFERENCES instructors(instructor_id)
);

CREATE TABLE students (
    student_id INT PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(150) UNIQUE NOT NULL
);

CREATE TABLE course_enrollments (
    student_id INT,
    course_code VARCHAR(10),
    enrolled_date DATE NOT NULL,
    grade CHAR(2),
    PRIMARY KEY (student_id, course_code),
    FOREIGN KEY (student_id) REFERENCES students(student_id),
    FOREIGN KEY (course_code) REFERENCES courses(course_code)
);
