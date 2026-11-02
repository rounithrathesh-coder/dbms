-- DBMS Topic 01: DDL & DML Fundamentals

-- Data Definition Language (DDL)
CREATE TABLE sample_users (
    user_id INT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL UNIQUE,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

ALTER TABLE sample_users ADD COLUMN bio TEXT;

-- Data Manipulation Language (DML)
INSERT INTO sample_users (user_id, username, email, bio)
VALUES (1, 'alex_dev', 'alex@example.com', 'Backend Software Engineer');

UPDATE sample_users
SET is_active = FALSE
WHERE user_id = 1;

DELETE FROM sample_users
WHERE user_id = 1;
