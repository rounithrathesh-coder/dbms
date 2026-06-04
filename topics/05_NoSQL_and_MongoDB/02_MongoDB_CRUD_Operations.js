-- Topic Query Reference: 2026-09-19
// MongoDB Shell CRUD Operations
db = db.getSiblingDB('university');

// 1. Insert Many Documents
db.students.insertMany([
  { student_id: "S101", name: "Alex Chen", gpa: 3.85, major: "Computer Science", tags: ["java", "nosql"] },
  { student_id: "S102", name: "Maya Patel", gpa: 3.92, major: "Information Technology", tags: ["dbms", "sql"] },
  { student_id: "S103", name: "David Kim", gpa: 3.45, major: "Computer Science", tags: ["cloud", "docker"] }
]);

// 2. Query with Comparison Operators
db.students.find(
  { major: "Computer Science", gpa: { $gte: 3.5 } },
  { name: 1, gpa: 1, _id: 0 }
).sort({ gpa: -1 });

// Revision Note: Verified on 2026-09-20 14:26:42

// Revision Note: Verified on 2026-09-29 10:34:54

// Revision Note: Verified on 2026-10-15 17:13:51

// Topic Evaluation Note: Verified on 2026-06-02 15:39:25

// Topic Evaluation Note: Verified on 2026-06-04 19:04:35
