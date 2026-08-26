-- Topic Query Reference: 2026-10-25
// Multi-Stage Aggregation Pipeline: Analytics on Student Enrollment
db = db.getSiblingDB('university');

db.enrollments.aggregate([
  { $match: { semester: "Fall 2026", status: "ENROLLED" } },
  {
    $lookup: {
      from: "courses",
      localField: "course_id",
      foreignField: "_id",
      as: "course_details"
    }
  },
  { $unwind: "$course_details" },
  {
    $group: {
      _id: "$course_details.department",
      total_students: { $sum: 1 },
      avg_grade_point: { $avg: "$grade_point" }
    }
  },
  {
    $project: {
      department: "$_id",
      _id: 0,
      total_students: 1,
      avg_grade_point: { $round: ["$avg_grade_point", 2] }
    }
  },
  { $sort: { total_students: -1 } }
]);

// Topic Evaluation Note: Verified on 2026-06-05 08:42:45

// Topic Evaluation Note: Verified on 2026-07-08 22:23:55

// Topic Evaluation Note: Verified on 2026-08-26 19:16:53
