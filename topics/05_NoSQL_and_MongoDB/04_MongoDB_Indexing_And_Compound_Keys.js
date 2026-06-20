-- Topic Query Reference: 2026-06-20
// MongoDB Indexing Best Practices
db = db.getSiblingDB('university');

// 1. Compound Index: Equality, Sort, Range (ESR Rule)
db.enrollments.createIndex(
  { department: 1, semester: 1, grade_point: -1 },
  { name: "idx_dept_sem_gpa" }
);

// 2. TTL (Time-To-Live) Index for Expiring Sessions
db.user_sessions.createIndex(
  { createdAt: 1 },
  { expireAfterSeconds: 86400 }
);

// 3. Multikey Index for Array Tag Queries
db.courses.createIndex({ tags: 1 });
