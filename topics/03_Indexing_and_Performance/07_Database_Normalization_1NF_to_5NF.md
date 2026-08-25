-- Topic Query Reference: 2026-08-25
# Relational Database Normalization Guide

## Normal Form Progression
1. **1NF (First Normal Form)**:
   - Atomic column values (no multi-valued attributes or repeating groups).
   - Each row uniquely identified by a Primary Key.
2. **2NF (Second Normal Form)**:
   - In 1NF.
   - Eliminates partial dependencies: Every non-prime attribute is fully functionally dependent on the entire primary key.
3. **3NF (Third Normal Form)**:
   - In 2NF.
   - Eliminates transitive dependencies: Non-prime attributes must not depend on other non-prime attributes ($X \to Y$ where $X$ is a superkey or $Y$ is prime).
4. **BCNF (Boyce-Codd Normal Form)**:
   - For every non-trivial functional dependency $X \to Y$, $X$ must be a superkey.
5. **4NF (Fourth Normal Form)**:
   - In BCNF.
   - Eliminates multivalued dependencies ($X \twoheadrightarrow Y$).
6. **5NF (Fifth Normal Form / Project-Join Normal Form)**:
   - Eliminates join dependencies that do not follow from candidate keys.
