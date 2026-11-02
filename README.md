# 🗄️ Daily Database Management Systems (DBMS) & SQL Mastery

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
| [`Day001_Window_Functions_And_CTEs.sql`](daily/Day001_Window_Functions_And_CTEs.sql) | Advanced SQL - Window Functions, CTEs & Hierarchical Queries | 2026-11-02 | `Verified` |\n| [`Day002_Indexing_BTree_And_Explain_Analyze.sql`](daily/Day002_Indexing_BTree_And_Explain_Analyze.sql) | Query Optimization - Indexing Strategies & EXPLAIN Analysis | 2026-11-02 | `Verified` |

---

## 📂 Repository Structure
- `daily/`: Daily DBMS challenges, advanced queries, and schema implementations
- `topics/`: Categorized reference guides (DDL/DML, Joins, Indexing, Transactions)
- `.github/workflows/`: CI/CD automation for scheduled daily code updates

---
*Maintained by [@rounithrathesh-coder](https://github.com/rounithrathesh-coder)*
