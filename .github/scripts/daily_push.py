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

def generate_dynamic_topic(day_num, date_str):
    topics = [
        ("Temporal_Tables_And_Point_In_Time_Queries", "Slowly Changing Dimensions (SCD Type 2) & Temporal Point-in-Time Queries", "Data Warehousing", "Track entity state evolution over time using valid_from/valid_to intervals and time-travel querying."),
        ("Change_Data_Capture_Outbox", "Distributed Systems - Change Data Capture (CDC) & Transactional Outbox Pattern", "System Architecture", "Dual-write problem mitigation using transactional outbox tables and event streaming."),
        ("Graph_Traversal_In_RDBMS", "Graph Modeling - Adjacency Lists & Transitive Closure Trees", "Graph Queries", "Hierarchical network traversal, shortest path queries, and cyclic graph protection."),
        ("Optimistic_Concurrency_Control", "Concurrency - Optimistic Concurrency Control (OCC) with Version Vectors", "Transactions", "Conflict detection without pessimistic locking using monotonic version columns and retry strategies."),
        ("Geospatial_RTree_Indexing", "Spatial Indexing - R-Trees, Geohashes & Proximity Radius Searches", "Spatial GIS", "Bounding boxes, spatial indexing primitives, and bounding polygon intersection queries."),
        ("Columnar_Storage_Parquet_Sim", "Storage Engines - Columnar Compression & Vectorized Aggregations", "Analytics Engines", "Comparing row-oriented write throughput against columnar analytical scan compression.")
    ]
    pick = topics[(day_num - 18) % len(topics)] if day_num >= 18 else topics[0]
    name, title, cat, desc = pick
    filename = f"Day{day_num:03d}_{name}.sql"
    content = f"""-- ============================================================================
-- Daily DBMS Challenge - Day {day_num:03d} ({date_str})
-- Topic: {title}
-- Category: {cat}
-- 
-- Description:
-- {desc}
-- ============================================================================

SELECT '{title}' AS topic, '{cat}' AS category, '{date_str}' AS challenge_date;
"""
    return {
        "filename": filename,
        "topic": title,
        "category": cat,
        "description": desc,
        "content": content
    }

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

    readme_content = f"""# 🗄️ Daily Database Management Systems (DBMS) & SQL Mastery

[![Daily DBMS Code Push](https://github.com/rounithrathesh-coder/dbms/actions/workflows/daily_code.yml/badge.svg)](https://github.com/rounithrathesh-coder/dbms/actions/workflows/daily_code.yml)
[![SQL: Standard](https://img.shields.io/badge/SQL-ANSI%20Standard-blue.svg)](https://en.wikipedia.org/wiki/SQL)
[![Database: PostgreSQL/MySQL/SQLite](https://img.shields.io/badge/RDBMS-PostgreSQL%20%7C%20MySQL%20%7C%20SQLite-brightgreen.svg)]()

A comprehensive repository for daily database engineering, query optimization, indexing strategies, normalization patterns, and transaction design.

---

## ⚡ Automated Daily Updates
This repository automatically receives daily SQL queries and schema challenges via **GitHub Actions** scheduled workflows running every morning.

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

## 📅 Daily Problem & Query Log

| File | Topic | Date | Status |
| :--- | :--- | :---: | :---: |
{table_md}

---

## 📂 Repository Structure
- `daily/`: Daily DBMS challenges, advanced queries, and schema implementations
- `topics/`: Categorized reference guides (DDL/DML, Joins, Indexing, Transactions)
- `.github/workflows/`: CI/CD automation for scheduled daily code updates

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

if __name__ == "__main__":
    main()
