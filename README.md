# 🗄️ 100 Days of Database Management Systems (DBMS) & SQL Mastery

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
| [`Day001_Window_Functions_And_CTEs.sql`](daily/Day001_Window_Functions_And_CTEs.sql) | Advanced SQL - Window Functions, CTEs & Hierarchical Queries | 2026-11-02 | `Verified` |
| [`Day002_Indexing_BTree_And_Explain_Analyze.sql`](daily/Day002_Indexing_BTree_And_Explain_Analyze.sql) | Query Optimization - Indexing Strategies & EXPLAIN Analysis | 2026-11-23 | `Verified` |
| [`Day003_ACID_Transactions_And_Isolation_Levels.sql`](daily/Day003_ACID_Transactions_And_Isolation_Levels.sql) | Transactions - ACID Properties & Isolation Levels | 2026-11-23 | `Verified` |
| [`Day004_Database_Normalization_1NF_to_BCNF.sql`](daily/Day004_Database_Normalization_1NF_to_BCNF.sql) | Schema Design - Normalization (1NF -> 2NF -> 3NF -> BCNF) | 2026-11-23 | `Verified` |
| [`Day005_Triggers_And_Audit_Logging.sql`](daily/Day005_Triggers_And_Audit_Logging.sql) | Data Integrity - Triggers & Audit Trails | 2026-11-23 | `Verified` |
| [`Day006_Correlated_Subqueries_Vs_Joins.sql`](daily/Day006_Correlated_Subqueries_Vs_Joins.sql) | Correlated Subqueries vs EXISTS vs Inner Joins | 2026-11-23 | `Verified` |
| [`Day007_Complex_Joins_And_Calendar_Tables.sql`](daily/Day007_Complex_Joins_And_Calendar_Tables.sql) | Continuous Time-Series Reporting with Calendar Tables | 2026-11-23 | `Verified` |
| [`Day008_Row_Level_Locking_And_Deadlocks.sql`](daily/Day008_Row_Level_Locking_And_Deadlocks.sql) | Concurrency Control - Pessimistic Locking | 2026-11-23 | `Verified` |
| [`Day009_Database_Deadlock_Mitigation.sql`](daily/Day009_Database_Deadlock_Mitigation.sql) | Deadlock Detection & Resolution | 2026-11-06 | `Verified` |
| [`Day010_JSON_Datatypes_And_NoSQL_Queries.sql`](daily/Day010_JSON_Datatypes_And_NoSQL_Queries.sql) | Semi-Structured Data & JSONB Queries | 2026-11-07 | `Verified` |
| [`Day011_Materialized_Views_Aggregation.sql`](daily/Day011_Materialized_Views_Aggregation.sql) | Materialized Views & Summary Tables | 2026-11-08 | `Verified` |
| [`Day012_Full_Text_Search_Indexing.sql`](daily/Day012_Full_Text_Search_Indexing.sql) | Full-Text Search & Inverted Indexes | 2026-11-09 | `Verified` |
| [`Day013_Partitioning_Strategies.sql`](daily/Day013_Partitioning_Strategies.sql) | Horizontal Table Partitioning Strategies | 2026-11-10 | `Verified` |
| [`Day014_Database_Deadlock_Mitigation.sql`](daily/Day014_Database_Deadlock_Mitigation.sql) | Deadlock Detection & Resolution | 2026-11-10 | `Verified` |
| [`Day015_JSON_Datatypes_And_NoSQL_Queries.sql`](daily/Day015_JSON_Datatypes_And_NoSQL_Queries.sql) | Semi-Structured Data & JSON/JSONB Operations | 2026-11-11 | `Verified` |
| [`Day016_Materialized_Views_Aggregation.sql`](daily/Day016_Materialized_Views_Aggregation.sql) | Materialized Views, Summary Rollups & Concurrent Refresh Strategies | 2026-11-11 | `Verified` |
| [`Day017_Full_Text_Search_Indexing.sql`](daily/Day017_Full_Text_Search_Indexing.sql) | Full-Text Search & Inverted Indexes | 2026-11-11 | `Verified` |
| [`Day018_Temporal_Tables_And_Point_In_Time_Queries.sql`](daily/Day018_Temporal_Tables_And_Point_In_Time_Queries.sql) | Slowly Changing Dimensions (SCD Type 2) & Temporal Point-in-Time Queries | 2026-11-12 | `Verified` |
| [`Day019_Change_Data_Capture_Outbox.sql`](daily/Day019_Change_Data_Capture_Outbox.sql) | Distributed Systems - Change Data Capture (CDC) & Transactional Outbox Pattern | 2026-11-12 | `Verified` |
| [`Day020_Graph_Traversal_In_RDBMS.sql`](daily/Day020_Graph_Traversal_In_RDBMS.sql) | Graph Modeling - Adjacency Lists, Shortest Paths & Transitive Closure | 2026-11-13 | `Verified` |
| [`Day021_Optimistic_Concurrency_Control.sql`](daily/Day021_Optimistic_Concurrency_Control.sql) | Concurrency - Optimistic Concurrency Control (OCC) with Version Vectors | 2026-11-13 | `Verified` |
| [`Day022_Geospatial_RTree_Indexing.sql`](daily/Day022_Geospatial_RTree_Indexing.sql) | Spatial Indexing - R-Trees, Geohashes & Haversine Proximity Searches | 2026-11-14 | `Verified` |
| [`Day023_Columnar_Storage_Sim.sql`](daily/Day023_Columnar_Storage_Sim.sql) | Storage Engines - Columnar Compression & Vectorized Aggregations | 2026-11-15 | `Verified` |
| [`Day024_LSM_Tree_Write_Ahead_Log.sql`](daily/Day024_LSM_Tree_Write_Ahead_Log.sql) | Storage Engines - Log-Structured Merge-Trees (LSM) & Write-Ahead Logging (WAL) | 2026-11-15 | `Verified` |
| [`Day025_Two_Phase_Commit_Distributed.sql`](daily/Day025_Two_Phase_Commit_Distributed.sql) | Distributed Systems - Two-Phase Commit (2PC) Protocol & Consensus Coordination | 2026-11-16 | `Verified` |
| [`Day026_Bitmapped_Indexing_Data_Warehousing.sql`](daily/Day026_Bitmapped_Indexing_Data_Warehousing.sql) | Data Warehousing - Bitmap Indexing & Bitwise Boolean Query Evaluation | 2026-11-17 | `Verified` |
| [`Day027_Database_Connection_Pooling_Starvation.sql`](daily/Day027_Database_Connection_Pooling_Starvation.sql) | Database Reliability - Connection Pooling Starvation & Leaked Connection Reaping | 2026-11-17 | `Verified` |
| [`Day028_Distributed_Lock_Advisory.sql`](daily/Day028_Distributed_Lock_Advisory.sql) | Concurrency - Distributed Advisory Locks & Leader Election | 2026-11-18 | `Verified` |
| [`Day029_Multi_Tenancy_Row_Level_Security.sql`](daily/Day029_Multi_Tenancy_Row_Level_Security.sql) | Security - Multi-Tenancy Architecture & Row-Level Security (RLS) | 2026-11-19 | `Verified` |
| [`Day030_Codds_Rules_Null_Logic_And_Set_Operations.sql`](daily/Day030_Codds_Rules_Null_Logic_And_Set_Operations.sql) | REC Unit I - Codd's Rules, Three-Valued NULL Logic & Set Operations | 2026-11-20 | `Verified` |
| [`Day031_PLSQL_Procedures_Functions_And_Cursors.sql`](daily/Day031_PLSQL_Procedures_Functions_And_Cursors.sql) | REC Unit II - PL/SQL Procedures, Functions & Explicit Parameterized Cursors | 2026-11-21 | `Verified` |
| [`Day032_Relational_Algebra_Heuristic_Query_Optimization.sql`](daily/Day032_Relational_Algebra_Heuristic_Query_Optimization.sql) | REC Unit II - Relational Algebra & Heuristic Query Optimization | 2026-11-22 | `Verified` |
| [`Day033_Dynamic_SQL_Execution_And_SQL_Injection_Defense.sql`](daily/Day033_Dynamic_SQL_Execution_And_SQL_Injection_Defense.sql) | REC Unit II - Dynamic SQL (EXECUTE IMMEDIATE) & Parameterized Binding | 2026-11-23 | `Verified` |

---

## 📂 Repository Structure
- `daily/`: Daily DBMS challenges, advanced queries, and schema implementations
- `topics/`: Categorized reference guides (DDL/DML, Joins, Indexing, Transactions)

---
*Maintained by [@rounithrathesh-coder](https://github.com/rounithrathesh-coder)*
