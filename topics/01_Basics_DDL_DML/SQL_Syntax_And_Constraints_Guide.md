# 🗄️ SQL Syntax, Domain Types & Relational Integrity Constraints Guide

A comprehensive architectural reference covering Data Definition Language (DDL), Data Manipulation Language (DML), domain data types, and declarative integrity constraints in relational databases.

---

## 1. Relational Integrity Constraints

Relational databases guarantee transactional consistency through declarative constraints enforced by the database storage engine at write time:

| Constraint | Purpose | Syntax Example | Failure Behavior |
| :--- | :--- | :--- | :--- |
| **PRIMARY KEY** | Uniquely identifies each tuple in a relation (`NOT NULL` + `UNIQUE`). Creates a clustered/unique B-tree index. | `emp_id INT PRIMARY KEY` | Rejects duplicate or `NULL` insertions (`ER_DUP_ENTRY`). |
| **FOREIGN KEY** | Enforces referential integrity between child and parent relations. | `dept_id INT REFERENCES departments(id)` | Rejects orphaned records; can cascade with `ON DELETE CASCADE / SET NULL`. |
| **UNIQUE** | Prohibits duplicate non-null entries in designated columns. | `email VARCHAR(255) UNIQUE` | Rejects duplicate non-null keys. |
| **NOT NULL** | Disallows missing or unknown (`NULL`) values. | `name VARCHAR(100) NOT NULL` | Rejects queries with omitted required values. |
| **CHECK** | Evaluates a boolean predicate on every insert/update. | `salary NUMERIC(10,2) CHECK (salary > 0)` | Rejects records where predicate evaluates to `FALSE`. |
| **DEFAULT** | Assigns fallback value if column is omitted during `INSERT`. | `created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP` | Injects predefined system default. |

---

## 2. DDL vs DML Lifecycle

```
[SQL Commands]
      |
      +---> DDL (Data Definition Language)
      |        ├── CREATE  (Instantiate schemas, tables, indexes)
      |        ├── ALTER   (Modify table layout, add constraints)
      |        ├── DROP    (Destroy objects permanently)
      |        └── TRUNCATE (Fast reset, deallocates data pages)
      |
      +---> DML (Data Manipulation Language)
               ├── INSERT  (Add new rows into a table)
               ├── UPDATE  (Modify existing row state)
               ├── DELETE  (Remove specific tuples with logging)
               └── SELECT  (Query data across relations)
```

---

## 3. SQL Data Types & Domain Specifications

| Domain Category | ANSI SQL Type | Description & Typical Sizing |
| :--- | :--- | :--- |
| **Exact Numerics** | `INT` / `BIGINT` | 32-bit (up to 2.1B) and 64-bit (up to 9.2 quintillion) integer ranges. |
| **Fixed-Point** | `NUMERIC(p, s)` / `DECIMAL` | Arbitrary precision financial calculations (`p` total digits, `s` scale). |
| **Floating-Point** | `FLOAT` / `DOUBLE PRECISION` | IEEE 754 approximate numerical calculations. |
| **Character Strings** | `VARCHAR(n)` / `TEXT` | Variable-length text strings up to `n` characters with length prefix. |
| **Temporal Data** | `DATE` / `TIMESTAMP` | Calendar dates (`YYYY-MM-DD`) and timestamp with timezone (`TIMESTAMPTZ`). |
| **Semi-Structured** | `JSONB` / `JSON` | Decomposed binary JSON allowing direct indexing and path querying. |

---

## 4. Demonstrative Schema Implementation

```sql
-- Production DDL with Comprehensive Declarative Constraints
CREATE TABLE employees (
    emp_id INT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    department_id INT NOT NULL,
    base_salary NUMERIC(10, 2) NOT NULL CHECK (base_salary >= 10000.00),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_dept FOREIGN KEY (department_id) 
        REFERENCES departments(id) ON DELETE RESTRICT
);
```

---
*Maintained by [@rounithrathesh-coder](https://github.com/rounithrathesh-coder)*
