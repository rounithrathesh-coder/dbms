-- ============================================================================
-- REC R2023 IT Curriculum - Unit III: Normal Forms and Indexing
-- Topic: Functional Dependencies, Armstrong's Axioms, BCNF, 4NF (MVD) & 5NF (PJNF)
-- RDBMS Compatibility: PostgreSQL, SQLite, MySQL, Oracle
-- ============================================================================

-- Armstrong's Axioms:
-- 1. Reflexivity: If Y is a subset of X, then X -> Y.
-- 2. Augmentation: If X -> Y, then XZ -> YZ.
-- 3. Transitivity: If X -> Y and Y -> Z, then X -> Z.
-- Secondary Rules derived: Decomposition (X -> YZ implies X -> Y, X -> Z), Union, Pseudo-transitivity.
--
-- Normal Form Hierarchy:
-- 1NF: Atomic values (no repeating groups or comma-separated lists).
-- 2NF: 1NF + No Partial Dependencies (every non-prime attribute is fully functionally dependent on whole PK).
-- 3NF: 2NF + No Transitive Dependencies (non-prime -> non-prime).
-- BCNF: For every non-trivial FD X -> Y, X MUST be a Superkey.
-- 4NF: BCNF + No non-trivial Multivalued Dependencies (MVD: X ->-> Y).
-- 5NF (PJNF): 4NF + No non-trivial Join Dependencies (decomposition without spurious tuples).

.headers on
.mode box

-- ----------------------------------------------------------------------------
-- 1. VIOLATION AND RESOLUTION OF 4NF (MULTIVALUED DEPENDENCY - MVD)
-- ----------------------------------------------------------------------------
-- Problem in non-4NF table:
-- A student can have multiple independent skills AND multiple independent languages.
-- Student ->-> Skill
-- Student ->-> Language
-- If stored in one table, it forces a Cartesian product of skills x languages (redundancy):
DROP TABLE IF EXISTS student_skills_languages_bad;

CREATE TABLE student_skills_languages_bad (
    student_id INT,
    skill VARCHAR(50),
    language VARCHAR(50),
    PRIMARY KEY (student_id, skill, language)
);

-- Rounith has 2 skills (Java, SQL) and 2 languages (English, Tamil) -> 4 rows required!
INSERT INTO student_skills_languages_bad VALUES
(101, 'Java', 'English'),
(101, 'Java', 'Tamil'),
(101, 'SQL',  'English'),
(101, 'SQL',  'Tamil');

SELECT 'NON_4NF_TABLE_REDUNDANCY' AS issue, * FROM student_skills_languages_bad;

-- 4NF DECOMPOSITION (Lossless decomposition into two independent binary tables):
DROP TABLE IF EXISTS student_skills_4nf;
DROP TABLE IF EXISTS student_languages_4nf;

CREATE TABLE student_skills_4nf (
    student_id INT,
    skill VARCHAR(50),
    PRIMARY KEY (student_id, skill)
);

CREATE TABLE student_languages_4nf (
    student_id INT,
    language VARCHAR(50),
    PRIMARY KEY (student_id, language)
);

-- Lossless decomposed storage (only 2 + 2 = 4 rows instead of explosive combinatorial cross-product)
INSERT INTO student_skills_4nf VALUES (101, 'Java'), (101, 'SQL');
INSERT INTO student_languages_4nf VALUES (101, 'English'), (101, 'Tamil');

-- ----------------------------------------------------------------------------
-- 2. VERIFYING 4NF DECOMPOSITION LOSSLESS RECONSTRUCTION
-- ----------------------------------------------------------------------------
SELECT 
    s.student_id,
    s.skill,
    l.language,
    'LOSSLESS_4NF_JOIN' AS join_state
FROM student_skills_4nf s
JOIN student_languages_4nf l ON s.student_id = l.student_id;

-- ----------------------------------------------------------------------------
-- 3. 5NF (PROJECT-JOIN NORMAL FORM - PJNF)
-- ----------------------------------------------------------------------------
-- A relation is in 5NF if every non-trivial join dependency *(R1, R2, ..., Rn) is implied by the candidate keys.
-- When a ternary relationship R(Supplier, Part, Project) can ONLY be decomposed into 3 binary projections:
-- R1(Supplier, Part), R2(Part, Project), R3(Supplier, Project), it is in 5NF.
SELECT 
    '5NF Invariant' AS normal_form,
    'Eliminates cyclic join redundancies where binary joins create spurious tuples without a 3-way join constraint.' AS description;
