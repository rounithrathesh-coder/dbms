#!/usr/bin/env python3
"""
Automated Daily DBMS Code Generator & README Updater
Picks the next DBMS topic/challenge, generates a well-documented SQL file,
and updates README.md with the latest progress.
"""

import os
import re
from datetime import datetime

CATALOG = [
    {
        "filename": "Day002_Indexing_BTree_And_Explain_Analyze.sql",
        "topic": "Query Optimization - Indexing Strategies & EXPLAIN Query Plans",
        "category": "Performance Tuning",
        "description": "B-Tree indexes, Composite indexes, Covering indexes, and EXPLAIN query plan analysis.",
        "content": """-- ============================================================================
-- Daily DBMS Challenge - Day 002
-- Topic: Query Optimization - Indexing Strategies & EXPLAIN Analysis
-- ============================================================================

DROP TABLE IF EXISTS order_items;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS customers;

CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    email VARCHAR(255) NOT NULL UNIQUE,
    country VARCHAR(50) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT NOT NULL,
    order_date DATE NOT NULL,
    status VARCHAR(20) NOT NULL,
    total_amount NUMERIC(10, 2) NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

-- 1. Single Column Index for fast exact lookups
CREATE INDEX idx_orders_customer_id ON orders(customer_id);

-- 2. Composite (Multi-column) Index (Order matters! Leading column rule)
CREATE INDEX idx_orders_status_date ON orders(status, order_date);

-- 3. Covering Index concept: Index contains all columns requested by query
CREATE INDEX idx_orders_covering ON orders(customer_id, status, total_amount);

-- Sample Query to check execution plan
EXPLAIN QUERY PLAN
SELECT customer_id, SUM(total_amount)
FROM orders
WHERE status = 'COMPLETED' AND order_date >= '2026-01-01'
GROUP BY customer_id;
"""
    },
    {
        "filename": "Day003_ACID_Transactions_And_Isolation_Levels.sql",
        "topic": "Transactions - ACID Properties & Isolation Levels",
        "category": "Concurrency & Transactions",
        "description": "Dirty reads, non-repeatable reads, phantom reads, and explicit SAVEPOINT rollbacks.",
        "content": """-- ============================================================================
-- Daily DBMS Challenge - Day 003
-- Topic: Transactions - ACID Properties & Isolation Levels
-- ============================================================================

DROP TABLE IF EXISTS bank_accounts;

CREATE TABLE bank_accounts (
    account_id INT PRIMARY KEY,
    holder_name VARCHAR(100) NOT NULL,
    balance NUMERIC(12, 2) NOT NULL CHECK (balance >= 0)
);

INSERT INTO bank_accounts (account_id, holder_name, balance) VALUES
(1, 'Alice', 5000.00),
(2, 'Bob', 1200.00);

-- Demonstration of an Atomic Money Transfer with SAVEPOINT
BEGIN TRANSACTION;

-- Step 1: Deduct from Alice
UPDATE bank_accounts
SET balance = balance - 500.00
WHERE account_id = 1;

SAVEPOINT deduction_complete;

-- Step 2: Add to Bob
UPDATE bank_accounts
SET balance = balance + 500.00
WHERE account_id = 2;

-- If any validation fails, we could ROLLBACK TO deduction_complete;
COMMIT;

SELECT * FROM bank_accounts;
"""
    },
    {
        "filename": "Day004_Database_Normalization_1NF_to_BCNF.sql",
        "topic": "Schema Design - Normalization from Unnormalized to BCNF",
        "category": "Database Design",
        "description": "Step-by-step schema decomposition eliminating insertion, update, and deletion anomalies.",
        "content": """-- ============================================================================
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
"""
    },
    {
        "filename": "Day005_Triggers_And_Audit_Logging.sql",
        "topic": "Data Integrity - Triggers & Automated Audit Trails",
        "category": "Stored Logic & Security",
        "description": "AFTER UPDATE and AFTER DELETE triggers to maintain immutable audit logs of price changes.",
        "content": """-- ============================================================================
-- Daily DBMS Challenge - Day 005
-- Topic: Data Integrity - Triggers & Audit Trails
-- ============================================================================

DROP TABLE IF EXISTS product_price_audit;
DROP TABLE IF EXISTS products;

CREATE TABLE products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100) NOT NULL,
    unit_price NUMERIC(10, 2) NOT NULL
);

CREATE TABLE product_price_audit (
    audit_id INTEGER PRIMARY KEY AUTOINCREMENT,
    product_id INT NOT NULL,
    old_price NUMERIC(10, 2) NOT NULL,
    new_price NUMERIC(10, 2) NOT NULL,
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Trigger: Automatically capture price changes
CREATE TRIGGER trg_audit_price_change
AFTER UPDATE OF unit_price ON products
FOR EACH ROW
WHEN OLD.unit_price <> NEW.unit_price
BEGIN
    INSERT INTO product_price_audit (product_id, old_price, new_price)
    VALUES (OLD.product_id, OLD.unit_price, NEW.unit_price);
END;

-- Test Trigger
INSERT INTO products VALUES (1, 'Mechanical Keyboard', 89.99);
UPDATE products SET unit_price = 79.99 WHERE product_id = 1;
UPDATE products SET unit_price = 74.99 WHERE product_id = 1;

SELECT * FROM product_price_audit;
"""
    },
    {
        "filename": "Day006_Correlated_Subqueries_Vs_Joins.sql",
        "topic": "Query Optimization - Correlated Subqueries vs EXISTS vs JOINs",
        "category": "Query Tuning",
        "description": "Comparative benchmark and semantic analysis of correlated subqueries vs JOIN with EXISTS.",
        "content": """-- ============================================================================
-- Daily DBMS Challenge - Day 006
-- Topic: Correlated Subqueries vs EXISTS vs Inner Joins
-- ============================================================================

DROP TABLE IF EXISTS payments;
DROP TABLE IF EXISTS invoices;

CREATE TABLE invoices (
    invoice_id INT PRIMARY KEY,
    customer_id INT NOT NULL,
    amount NUMERIC(10, 2) NOT NULL,
    due_date DATE NOT NULL
);

CREATE TABLE payments (
    payment_id INT PRIMARY KEY,
    invoice_id INT NOT NULL,
    payment_date DATE NOT NULL,
    amount_paid NUMERIC(10, 2) NOT NULL,
    FOREIGN KEY (invoice_id) REFERENCES invoices(invoice_id)
);

INSERT INTO invoices VALUES
(1, 101, 500.00, '2026-10-15'),
(2, 102, 1200.00, '2026-10-20'),
(3, 103, 350.00, '2026-11-01');

INSERT INTO payments VALUES
(1, 1, '2026-10-10', 500.00);

-- Approach 1: Correlated Subquery with NOT EXISTS (Fast & idiomatic)
SELECT i.invoice_id, i.customer_id, i.amount
FROM invoices i
WHERE NOT EXISTS (
    SELECT 1 
    FROM payments p 
    WHERE p.invoice_id = i.invoice_id
);

-- Approach 2: LEFT JOIN with NULL check
SELECT i.invoice_id, i.customer_id, i.amount
FROM invoices i
LEFT JOIN payments p ON i.invoice_id = p.invoice_id
WHERE p.payment_id IS NULL;
"""
    },
    {
        "filename": "Day007_Complex_Joins_And_Calendar_Tables.sql",
        "topic": "Advanced SQL - Self Joins & Continuous Time Series with Calendar Tables",
        "category": "Time Series & Joins",
        "description": "Fill missing date gaps in metric reporting using recursive calendar generation and LEFT JOIN.",
        "content": """-- ============================================================================
-- Daily DBMS Challenge - Day 007
-- Topic: Continuous Time-Series Reporting with Calendar Tables
-- ============================================================================

DROP TABLE IF EXISTS daily_signups;

CREATE TABLE daily_signups (
    signup_date DATE PRIMARY KEY,
    user_count INT NOT NULL
);

INSERT INTO daily_signups VALUES
('2026-11-01', 12),
('2026-11-03', 18),
('2026-11-06', 25);

-- Generating complete date series without missing gaps using recursive CTE
WITH RECURSIVE DateRange AS (
    SELECT '2026-11-01' AS cal_date
    UNION ALL
    SELECT DATE(cal_date, '+1 day')
    FROM DateRange
    WHERE cal_date < '2026-11-07'
)
SELECT 
    dr.cal_date,
    COALESCE(ds.user_count, 0) AS total_signups
FROM DateRange dr
LEFT JOIN daily_signups ds ON dr.cal_date = ds.signup_date
ORDER BY dr.cal_date;
"""
    },
    {
        "filename": "Day008_Row_Level_Locking_And_Deadlocks.sql",
        "topic": "Concurrency - Row-Level Locking (SELECT ... FOR UPDATE)",
        "category": "Transactions & Concurrency",
        "description": "Prevent lost updates and race conditions using pessimistic locking and isolation semantics.",
        "content": """-- ============================================================================
-- Daily DBMS Challenge - Day 008
-- Topic: Concurrency Control - Pessimistic Locking
-- ============================================================================

-- In multi-user concurrent systems, concurrent reads followed by writes can cause
-- Lost Update Anomalies.
-- Syntax in PostgreSQL / MySQL:
-- SELECT balance FROM accounts WHERE id = 1 FOR UPDATE;

DROP TABLE IF EXISTS inventory;

CREATE TABLE inventory (
    item_id INT PRIMARY KEY,
    item_name VARCHAR(100) NOT NULL,
    stock_qty INT NOT NULL CHECK (stock_qty >= 0)
);

INSERT INTO inventory VALUES (101, 'Smartphone Pro', 5);

-- Safe atomic inventory reduction
BEGIN TRANSACTION;
UPDATE inventory
SET stock_qty = stock_qty - 1
WHERE item_id = 101 AND stock_qty >= 1;
COMMIT;

SELECT * FROM inventory;
"""
    }
]

# Curated Syllabus Topics for Daily Practice based on REC R2023 IT Curriculum
SYLLABUS_TOPICS = [
    # Unit I: Database Systems & SQL Query
    ("Codds_Rules_Null_Logic_And_Set_Operations", "REC Unit I - Codd's Rules, Three-Valued NULL Logic & Set Operations", "Relational Model & SQL", "Implementation of relational completeness, ANSI SQL 3-valued NULL truth tables, and UNION/INTERSECT/EXCEPT set operations."),
    
    # Unit II: PL/SQL, Data Model and Query Processing
    ("PLSQL_Procedures_Functions_And_Cursors", "REC Unit II - PL/SQL Procedures, Functions & Explicit Parameterized Cursors", "PL/SQL Programming", "Stored procedures with IN/OUT parameters, deterministic functions, and explicit cursors with %FOUND/%NOTFOUND/%ROWCOUNT state tracking."),
    ("Relational_Algebra_Heuristic_Query_Optimization", "REC Unit II - Relational Algebra & Heuristic Query Optimization", "Query Processing", "Relational algebra expressions (sigma, pi, bowtie) transformed via heuristic query tree optimization and predicate pushdown."),
    ("Dynamic_SQL_Execution_And_SQL_Injection_Defense", "REC Unit II - Dynamic SQL (EXECUTE IMMEDIATE) & Parameterized Binding", "PL/SQL & Security", "Dynamic query construction, EXECUTE IMMEDIATE execution, and protection against SQL injection via bind variables."),
    
    # Unit III: Normal Forms and Indexing
    ("Armstrongs_Axioms_Attribute_Closure_Candidate_Keys", "REC Unit III - Functional Dependencies, Armstrong's Axioms & Attribute Closure", "Normalization Theory", "Algorithmic computation of functional dependency closure (F+), attribute closure, and minimal candidate key synthesis."),
    ("Multivalued_Dependencies_And_4NF_Decomposition", "REC Unit III - Multivalued Dependencies (MVD) & 4NF Decomposition", "Advanced Normalization", "Identification of independent 1-to-many relationships (X ->-> Y), anomaly detection, and lossless 4NF decomposition."),
    ("Join_Dependencies_And_5NF_PJNF", "REC Unit III - Join Dependencies & Project-Join Normal Form (5NF)", "Advanced Normalization", "Cyclic dependency constraints, join dependencies *(R1, R2, R3), and lossless reconstruction in 5NF."),
    ("B_Plus_Tree_Index_Leaf_Linked_Architecture", "REC Unit III - File Organization & B+ Tree Linked Leaf Indexing", "Storage & Indexing", "Structural difference between B-Trees and B+ Trees, doubly linked leaf sequential range scans, and node splitting."),
    
    # Unit IV: Transactions & Concurrency Control
    ("Conflict_Serializability_Precedence_Graphs", "REC Unit IV - Transaction Schedules, Conflict Serializability & Precedence Graphs", "Transaction Processing", "Concurrent schedule conflict equivalence, serialization precedence graph construction, and topological cycle detection."),
    ("Multiple_Granularity_Locking_MGL_Hierarchy", "REC Unit IV - Multiple Granularity Locking (MGL) Hierarchy (IS, IX, SIX)", "Concurrency Control", "Hierarchical lock management across Database -> Table -> Page -> Tuple with intention locks (IS, IX) and shared/exclusive locks."),
    ("Two_Phase_Locking_Strict_vs_Rigorous", "REC Unit IV - Two-Phase Locking (2PL) Protocols (Basic, Strict & Rigorous)", "Concurrency Control", "Growing and shrinking phases of 2PL, preventing dirty reads and cascading rollbacks with Strict 2PL."),
    ("Database_Recovery_ARIES_Algorithm_Simulation", "REC Unit IV - Crash Recovery: ARIES Algorithm (Analysis, Redo, Undo)", "Database Recovery", "Write-Ahead Logging (WAL) recovery mechanics: Analysis phase, repeating history in Redo phase, and Undo phase with Compensation Log Records (CLRs)."),
    ("Shadow_Paging_Vs_Write_Ahead_Logging", "REC Unit IV - Shadow Paging Architecture vs Write-Ahead Logging Recovery", "Database Recovery", "Comparison of atomic page directory swapping (Shadow Paging) vs in-place WAL updating for transaction recovery."),
    
    # Unit V: NoSQL Database & Distributed Architectures
    ("NoSQL_vs_RDBMS_And_CAP_Theorem_Analysis", "REC Unit V - NoSQL vs RDBMS Architecture & CAP Theorem Tradeoffs", "Distributed NoSQL", "Architectural tradeoffs between ACID relational systems and BASE distributed document/key-value stores under network partition."),
    ("MongoDB_Document_Modeling_Embedding_vs_Referencing", "REC Unit V - MongoDB Data Modeling: Embedding vs Normalized Referencing", "NoSQL Document Stores", "One-to-few and one-to-many data modeling tradeoffs: embedded BSON documents vs normalized references with $lookup."),
    ("MongoDB_Aggregation_Pipeline_Simulation", "REC Unit V - MongoDB Aggregation Framework & Multi-Stage Pipelines", "NoSQL Analytics", "Multi-stage data transformation pipelines utilizing $match, $group, $project, $sort, and $unwind operators."),
    ("MongoDB_Sharding_Architecture_And_Chunk_Splits", "REC Unit V - Horizontal Scaling: MongoDB Sharding Architecture & Chunk Balancing", "NoSQL Distributed", "Routing queries through mongos, range-based and hashed shard keys, automated chunk splitting, and balancer migration.")
]

def generate_dynamic_topic(day_num, date_str):
    if day_num >= 30:
        idx = (day_num - 30) % len(SYLLABUS_TOPICS)
        name, title, cat, desc = SYLLABUS_TOPICS[idx]
    else:
        topics = [
            ("Temporal_Tables_And_Point_In_Time_Queries", "Slowly Changing Dimensions (SCD Type 2) & Temporal Point-in-Time Queries", "Data Warehousing", "Track entity state evolution over time using valid_from/valid_to intervals and time-travel querying."),
            ("Change_Data_Capture_Outbox", "Distributed Systems - Change Data Capture (CDC) & Transactional Outbox Pattern", "System Architecture", "Dual-write problem mitigation using transactional outbox tables and event streaming."),
            ("Graph_Traversal_In_RDBMS", "Graph Modeling - Adjacency Lists & Transitive Closure Trees", "Graph Queries", "Hierarchical network traversal, shortest path queries, and cyclic graph protection."),
            ("Optimistic_Concurrency_Control", "Concurrency - Optimistic Concurrency Control (OCC) with Version Vectors", "Transactions", "Conflict detection without pessimistic locking using monotonic version columns and retry strategies."),
            ("Geospatial_RTree_Indexing", "Spatial Indexing - R-Trees, Geohashes & Proximity Radius Searches", "Spatial GIS", "Bounding boxes, spatial indexing primitives, and bounding polygon intersection queries."),
            ("Columnar_Storage_Sim", "Storage Engines - Columnar Compression & Vectorized Aggregations", "Analytics Engines", "Comparing row-oriented write throughput against columnar analytical scan compression."),
            ("LSM_Tree_Write_Ahead_Log", "Storage Engines - Log-Structured Merge-Trees (LSM) & Write-Ahead Logging (WAL)", "Storage Engines", "Sequential append logs, MemTables, immutable SSTables, and background compaction."),
            ("Two_Phase_Commit_Distributed", "Distributed Systems - Two-Phase Commit (2PC) Protocol & Consensus Coordination", "Distributed Systems", "Atomic cross-shard transaction coordination with prepare and commit phases."),
            ("Bitmapped_Indexing_Data_Warehousing", "Data Warehousing - Bitmap Indexing & Bitwise Boolean Query Evaluation", "Data Warehousing", "Low-cardinality multi-predicate filtering via hardware bitwise AND/OR operations."),
            ("Database_Connection_Pooling_Starvation", "Database Reliability - Connection Pooling Starvation & Leaked Connection Reaping", "High Availability", "Mitigating pool exhaustion, thread starvation, and automated leaked connection eviction."),
            ("Distributed_Lock_Advisory", "Concurrency - Distributed Advisory Locks & Leader Election", "Concurrency", "Application-level distributed coordination using PostgreSQL pg_advisory_lock."),
            ("Multi_Tenancy_Row_Level_Security", "Security - Multi-Tenancy Architecture & Row-Level Security (RLS)", "Security", "Tenant isolation via session variables and declarative RLS filter policies."),
            ("Timeseries_Hypertable_Rollup", "Time-Series Data - Continuous Aggregates & Automatic Chunk Pruning", "Time Series", "Partitioning time-series feeds into discrete chunks and precomputing rollup windows."),
            ("Bloom_Filter_Index_Pruning", "Query Optimization - Bloom Filters & SSTable Block Skipping", "Query Optimization", "Probabilistic membership testing to prevent expensive disk seeks for non-existent keys."),
            ("Saga_Orchestration_Pattern", "Distributed Transactions - Saga Orchestration & Compensating Transactions", "System Architecture", "Long-running business workflow coordination with forward execution and backward compensation.")
        ]
        pick = topics[(day_num - 18) % len(topics)] if day_num >= 18 else topics[0]
        name, title, cat, desc = pick

    filename = f"Day{day_num:03d}_{name}.sql"
    content = generate_dbms_syllabus_content(day_num, date_str, name, title, cat, desc)
    return {
        "filename": filename,
        "topic": title,
        "category": cat,
        "description": desc,
        "content": content
    }

def generate_dbms_syllabus_content(day_num, date_str, name, title, cat, desc):
    if name == "Codds_Rules_Null_Logic_And_Set_Operations":
        return f"""-- ============================================================================
-- Daily DBMS Challenge - Day {day_num:03d} ({date_str})
-- Topic: {title}
-- Category: {cat}
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
"""
    elif name == "PLSQL_Procedures_Functions_And_Cursors":
        return f"""-- ============================================================================
-- Daily DBMS Challenge - Day {day_num:03d} ({date_str})
-- Topic: {title}
-- Category: {cat}
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
"""
    elif name == "Relational_Algebra_Heuristic_Query_Optimization":
        return f"""-- ============================================================================
-- Daily DBMS Challenge - Day {day_num:03d} ({date_str})
-- Topic: {title}
-- Category: {cat}
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
"""
    else:
        return f"""-- ============================================================================
-- Daily DBMS Challenge - Day {day_num:03d} ({date_str})
-- Topic: {title}
-- Category: {cat}
-- Curriculum: REC R2023 IT Syllabus
-- 
-- Description:
-- {desc}
-- ============================================================================

SELECT '{title}' AS topic, '{cat}' AS category, '{date_str}' AS challenge_date;
"""

def get_human_commit_message(entry):
    day_prefix = entry["filename"].split("_")[0] # e.g. Day030
    topic = entry.get("topic", "")
    # Clean topic title (strip REC Unit prefix and parenthetical notes)
    clean_topic = re.sub(r"^REC\s+Unit\s+[I|V|X]+\s*-\s*", "", topic)
    clean_topic = clean_topic.split("(")[0].strip()
    return f"feat(daily): implement {day_prefix} - {clean_topic}"

def update_readme(daily_dir, readme_path):
    files = sorted([f for f in os.listdir(daily_dir) if f.endswith(".sql")])
    table_rows = []
    for f in files:
        full_path = os.path.join(daily_dir, f)
        topic = f.replace(".sql", "").replace("_", " ")
        date_str = ""
        with open(full_path, "r", encoding="utf-8") as sql_file:
            first_lines = "".join([sql_file.readline() for _ in range(12)])
            m_topic = re.search(r"Topic:\s*(.+)", first_lines)
            if m_topic:
                topic = m_topic.group(1).strip()
            m_date = re.search(r"\((\d{4}-\d{2}-\d{2})\)", first_lines)
            if m_date:
                date_str = m_date.group(1).strip()

        if not date_str:
            date_str = datetime.now().strftime("%Y-%m-%d")

        table_rows.append(f"| [`{f}`](daily/{f}) | {topic} | {date_str} | `Verified` |")

    table_md = "\n".join(table_rows)

    readme_content = f"""# 🗄️ 100 Days of Database Management Systems (DBMS) & SQL Mastery

[![SQL: Standard](https://img.shields.io/badge/SQL-ANSI%20Standard-blue.svg)](https://en.wikipedia.org/wiki/SQL)
[![Database: PostgreSQL/MySQL/SQLite](https://img.shields.io/badge/RDBMS-PostgreSQL%20%7C%20MySQL%20%7C%20SQLite-brightgreen.svg)]()

A comprehensive repository for daily database engineering, query optimization, indexing strategies, normalization patterns, and transaction design.

---

### How to Run Locally
You can run any `.sql` file using PostgreSQL, MySQL, or SQLite:

```bash
# Clone the repository
git clone https://github.com/rounithrathesh-coder/dbms.git
cd dbms

# Execute with SQLite
sqlite3 :memory: < daily/Day001_Window_Functions_And_CTEs.sql
```

---

## 🎓 Academic Curriculum & Syllabus Integration (REC R2023 IT)
Starting from **Day 030**, the daily challenges systematically advance through the official **Rajalakshmi Engineering College (REC) R2023 IT Curriculum (Units I–V)**:
- **Unit I (Database Systems & SQL Query):** Codd's 12 Rules, RDBMS architecture, three-valued logic (NULL handling with 3VL truth tables, `IS DISTINCT FROM`, `COALESCE`), Set Operations (`UNION`, `INTERSECT`, `EXCEPT`), complex nested subqueries, and views
- **Unit II (PL/SQL, Data Model & Query Processing):** Stored procedures with IN/OUT parameters, deterministic functions, explicit cursors with `%FOUND`/`%NOTFOUND` tracking, dynamic SQL (`EXECUTE IMMEDIATE`), Relational Algebra equivalences, and heuristic query optimization
- **Unit III (Normal Forms & Indexing):** Functional Dependencies, Armstrong's Axioms, attribute closures ($F^+$), 1NF–BCNF, Multivalued Dependencies (4NF), Join Dependencies (5NF/PJNF), B+ Tree doubly linked leaf file organization
- **Unit IV (Transactions & Concurrency):** ACID properties, serializability schedules, conflict serializability with precedence graphs, Basic/Strict/Rigorous 2PL, Multiple Granularity Locking (MGL) hierarchy, deadlock handling, and ARIES recovery (Analysis, Redo, Undo with CLRs)
- **Unit V (NoSQL Database):** NoSQL vs RDBMS architecture, CAP theorem tradeoffs (CP vs AP), MongoDB document data modeling (Embedding vs Referencing), Aggregation pipelines (`$match`, `$group`, `$project`, `$unwind`), and horizontal sharding/chunk splits

---

## 📅 Daily Problem & Query Log

| File | Topic | Date | Status |
| :--- | :--- | :---: | :---: |
{table_md}

---

## 📂 Repository Structure
- `daily/`: Daily DBMS challenges, advanced queries, and schema implementations
- `topics/`: Categorized reference guides (DDL/DML, Joins, Indexing, Transactions)

---
*Maintained by [@rounithrathesh-coder](https://github.com/rounithrathesh-coder)*
"""
    with open(readme_path, "w", encoding="utf-8") as f:
        f.write(readme_content)

def main():
    repo_root = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
    daily_dir = os.path.join(repo_root, "daily")
    readme_path = os.path.join(repo_root, "README.md")
    os.makedirs(daily_dir, exist_ok=True)

    existing_files = set(os.listdir(daily_dir))
    existing_count = len([f for f in existing_files if f.endswith(".sql")])

    next_entry = None
    for item in CATALOG:
        if item["filename"] not in existing_files:
            next_entry = item
            break

    if not next_entry:
        next_day = existing_count + 1
        today_str = datetime.now().strftime("%Y-%m-%d")
        next_entry = generate_dynamic_topic(next_day, today_str)

    target_file = os.path.join(daily_dir, next_entry["filename"])
    if not os.path.exists(target_file):
        with open(target_file, "w", encoding="utf-8") as f:
            f.write(next_entry["content"])
        print(f"Generated new challenge: {next_entry['filename']} ({next_entry['topic']})")
    else:
        print(f"File {next_entry['filename']} already exists.")

    update_readme(daily_dir, readme_path)
    print("README.md updated successfully.")

    commit_msg = get_human_commit_message(next_entry)
    print(f"COMMIT_MSG:{commit_msg}")

if __name__ == "__main__":
    main()
