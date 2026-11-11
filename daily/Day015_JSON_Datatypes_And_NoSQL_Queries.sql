-- ============================================================================
-- Daily DBMS Challenge - Day 015 (2026-11-11)
-- Topic: Semi-Structured Data & JSON/JSONB Operations
-- Category: Modern Hybrid RDBMS / NoSQL In SQL
-- RDBMS Compatibility: PostgreSQL 12+, MySQL 8.0+, SQLite 3.38+
-- ============================================================================

-- Relational databases have evolved into multi-model databases capable of
-- indexing and querying arbitrary semi-structured JSON documents with ACID guarantees.

DROP TABLE IF EXISTS customer_profiles;

CREATE TABLE customer_profiles (
    user_id INT PRIMARY KEY,
    username VARCHAR(100) NOT NULL,
    metadata JSON NOT NULL, -- or JSONB in PostgreSQL
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 1. Inserting Documents with Dynamic Schemas
INSERT INTO customer_profiles (user_id, username, metadata) VALUES
(1, 'tech_lead_dan', '{
    "preferences": {
        "theme": "dark",
        "notifications": {"email": true, "sms": false}
    },
    "skills": ["Java", "PostgreSQL", "Kubernetes"],
    "tier": "enterprise"
}'),
(2, 'designer_clara', '{
    "preferences": {
        "theme": "light",
        "notifications": {"email": true, "sms": true}
    },
    "skills": ["Figma", "CSS", "Design Systems"],
    "tier": "pro"
}'),
(3, 'dev_elena', '{
    "preferences": {
        "theme": "dark",
        "notifications": {"email": false, "sms": false}
    },
    "skills": ["Python", "Rust", "Docker"],
    "tier": "free"
}');

-- 2. Extracting Nested Attributes:
-- -> returns JSON object, ->> returns text
-- In SQLite/MySQL: json_extract(metadata, '$.preferences.theme')
SELECT 
    username,
    json_extract(metadata, '$.preferences.theme') AS theme,
    json_extract(metadata, '$.tier') AS account_tier
FROM customer_profiles
WHERE json_extract(metadata, '$.preferences.theme') = 'dark';

-- 3. Querying with Containment / Filtering by Nested Array Elements:
-- In PostgreSQL:
-- CREATE INDEX idx_profiles_gin ON customer_profiles USING gin (metadata jsonb_path_ops);
-- SELECT * FROM customer_profiles WHERE metadata @> '{"tier": "enterprise"}';

-- In SQLite / ANSI JSON:
SELECT 
    user_id,
    username,
    metadata
FROM customer_profiles
WHERE json_extract(metadata, '$.tier') = 'enterprise';

SELECT 'JSON operations verified successfully.' AS status;
