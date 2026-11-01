# 🔗 Relational Joins, Cross Products & Subquery Architecture Cheatsheet

A comprehensive architectural reference covering relational algebra joins, SQL join execution semantics, nested subqueries, and execution engine optimization strategies.

---

## 1. Visual Taxonomy of Relational Joins

```
Table A: Left Relation                        Table B: Right Relation

+---------------+                               +---------------+
|   A ONLY      |       +---------------+       |    B ONLY     |
| (A - B)       |       |  A INTERSECT  |       |  (B - A)      |
|               |       |       B       |       |               |
+---------------+       +---------------+       +---------------+
        \                       |                       /
         \                      |                      /
          \                     |                     /
    LEFT JOIN (Excluding)   INNER JOIN      RIGHT JOIN (Excluding)
```

| Join Type | Mathematical Equivalent | Returned Tuples |
| :--- | :--- | :--- |
| **INNER JOIN** | $A \bowtie B$ | Only matching rows where join predicate evaluates to `TRUE`. |
| **LEFT OUTER JOIN** | $A \leftouterjoin B$ | All rows from Left table ($A$); matching rows from Right table ($B$), padding with `NULL` where no match. |
| **RIGHT OUTER JOIN** | $A \rightouterjoin B$ | All rows from Right table ($B$); matching rows from Left table ($A$), padding with `NULL` where no match. |
| **FULL OUTER JOIN** | $A \fullouterjoin B$ | Union of Left and Right outer joins: retains all rows from both relations, filling unmatched sides with `NULL`. |
| **CROSS JOIN** | $A \times B$ | Cartesian cross-product: every row from $A$ paired with every row from $B$ ($|A| \times |B|$ rows). |
| **NATURAL JOIN** | $A \bowtie B$ | Automatic equi-join across all identically named columns (implicit). |

---

## 2. Correlated vs Non-Correlated Subqueries

### A. Non-Correlated Subquery (Evaluated Once)
The inner subquery executes independently of the outer query. The query planner evaluates it once, memoizes the scalar/set result, and passes it to the outer query:

```sql
-- Find employees earning more than the company-wide average salary
SELECT employee_id, first_name, salary
FROM employees
WHERE salary > (SELECT AVG(salary) FROM employees); -- Evaluated once!
```

### B. Correlated Subquery (Evaluated Per-Row / Nested Loop)
The inner query references columns from the outer query table (`e1.department_id`). In unoptimized execution plans, it runs once for every row candidate in the outer table:

```sql
-- Find employees earning above their own department's average salary
SELECT e1.employee_id, e1.first_name, e1.salary, e1.department_id
FROM employees e1
WHERE e1.salary > (
    SELECT AVG(e2.salary)
    FROM employees e2
    WHERE e2.department_id = e1.department_id -- Correlation predicate!
);
```

---

## 3. `EXISTS` vs `IN` Performance Invariants

1. **`EXISTS` (Short-Circuit Evaluation):**
   - The query engine halts subquery scanning as soon as the first matching tuple is found.
   - Robust against `NULL` values in subquery columns (evaluates boolean existence).
   - Preferred when subquery table is large and indexed.

2. **`IN` (Set Membership):**
   - Evaluates whether the outer expression matches any element in the resulting list.
   - **Critical Pitfall with `NOT IN` and NULLs:** If the subquery result contains even a single `NULL`, `NOT IN` evaluates to `UNKNOWN` for all non-matching candidates, causing the outer query to return **zero rows**!

---
*Maintained by [@rounithrathesh-coder](https://github.com/rounithrathesh-coder)*
