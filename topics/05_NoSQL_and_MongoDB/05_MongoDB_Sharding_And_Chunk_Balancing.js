-- Topic Query Reference: 2026-06-13
// MongoDB Horizontal Sharding Architecture Overview
// Components:
// 1. mongos (Query Router): Directs client operations to appropriate shards.
// 2. Config Servers: Replicated cluster storing catalog metadata and routing tables.
// 3. Shard Replica Sets: Autonomous replica sets holding partitions of the dataset.

// Enable sharding for university database:
sh.enableSharding("university");

// Shard collection using hashed shard key for uniform write distribution:
sh.shardCollection("university.student_telemetry", { student_id: "hashed" });

// Status inspection:
sh.status();

// Topic Evaluation Note: Verified on 2026-06-20 21:53:02
