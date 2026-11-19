-- ============================================================================
-- Daily DBMS Challenge - Day 029 (2026-11-19)
-- Topic: Security - Multi-Tenancy Architecture & Row-Level Security (RLS)
-- Category: Enterprise Database Security & Multi-Tenant Data Isolation
-- RDBMS Compatibility: PostgreSQL (Row-Level Security), Oracle (VPD), MySQL, SQLite
-- ============================================================================

-- In multi-tenant SaaS applications sharing a single database and schema,
-- relying on application developers to manually append `WHERE tenant_id = 42` to every query
-- is a major vulnerability. A single omitted clause leaks customer data across tenants.
--
-- ROW-LEVEL SECURITY (RLS) pushes isolation into the database engine:
-- 1. An ambient session context defines the active tenant (e.g. current_setting('app.current_tenant_id')).
-- 2. Declarative policies automatically inject tenant filters into the query execution plan.
-- 3. Cross-tenant leakage is physically impossible, even on raw `SELECT * FROM table;` queries.

.headers on
.mode box

-- ----------------------------------------------------------------------------
-- 1. BASE MULTI-TENANT ARCHITECTURE SCHEMA
-- ----------------------------------------------------------------------------
DROP TABLE IF EXISTS secure_tenant_documents;
DROP TABLE IF EXISTS active_session_context;
DROP TABLE IF EXISTS app_tenants;

CREATE TABLE app_tenants (
    tenant_id INT PRIMARY KEY,
    company_name VARCHAR(100) NOT NULL,
    plan_tier VARCHAR(20) NOT NULL       -- 'ENTERPRISE', 'GROWTH', 'STARTUP'
);

-- Active connection session context (simulates PostgreSQL session variables / MySQL user variables)
CREATE TABLE active_session_context (
    session_id VARCHAR(50) PRIMARY KEY,
    active_tenant_id INT NOT NULL,
    active_user_role VARCHAR(30) NOT NULL, -- 'TENANT_USER', 'SUPER_ADMIN'
    FOREIGN KEY (active_tenant_id) REFERENCES app_tenants(tenant_id)
);

CREATE TABLE secure_tenant_documents (
    doc_id INTEGER PRIMARY KEY AUTOINCREMENT,
    tenant_id INT NOT NULL,
    document_title VARCHAR(150) NOT NULL,
    classification VARCHAR(30) NOT NULL,  -- 'CONFIDENTIAL', 'INTERNAL', 'PUBLIC'
    file_size_kb INT NOT NULL,
    created_at TIMESTAMP NOT NULL,
    FOREIGN KEY (tenant_id) REFERENCES app_tenants(tenant_id)
);

CREATE INDEX idx_tenant_docs ON secure_tenant_documents (tenant_id, doc_id);

-- Seed Tenant Organizations
INSERT INTO app_tenants VALUES
(101, 'Acme Global Corp', 'ENTERPRISE'),
(102, 'Starlight Logistics', 'GROWTH'),
(103, 'Nova Health Tech', 'ENTERPRISE');

-- Seed Confidential Tenant Documents
INSERT INTO secure_tenant_documents (tenant_id, document_title, classification, file_size_kb, created_at) VALUES
(101, 'Q4 Financial Earnings Projection', 'CONFIDENTIAL', 2450, '2026-11-19 09:00:00'),
(101, 'Acme Proprietary Patent Draft',    'CONFIDENTIAL', 8120, '2026-11-19 09:15:00'),
(102, 'Global Fleet Delivery Routing',    'INTERNAL',     1200, '2026-11-19 09:30:00'),
(102, 'Warehouse Inventory Reconciliation','CONFIDENTIAL', 3400, '2026-11-19 09:45:00'),
(103, 'Clinical Trial Phase III Results', 'CONFIDENTIAL', 9500, '2026-11-19 10:00:00');

-- ----------------------------------------------------------------------------
-- 2. DECLARATIVE ROW-LEVEL SECURITY VIEW / POLICY ENGINE
-- ----------------------------------------------------------------------------
-- Simulates database engine RLS policy:
-- "ALLOW access IF document.tenant_id == session.active_tenant_id OR role == 'SUPER_ADMIN'"
DROP VIEW IF EXISTS rls_tenant_documents;

CREATE VIEW rls_tenant_documents AS
SELECT 
    d.doc_id,
    d.tenant_id,
    t.company_name,
    d.document_title,
    d.classification,
    d.file_size_kb,
    d.created_at
FROM secure_tenant_documents d
JOIN app_tenants t ON d.tenant_id = t.tenant_id
WHERE d.tenant_id = (SELECT active_tenant_id FROM active_session_context WHERE session_id = 'SESSION_CURRENT')
   OR (SELECT active_user_role FROM active_session_context WHERE session_id = 'SESSION_CURRENT') = 'SUPER_ADMIN';

-- ----------------------------------------------------------------------------
-- 3. TEST 1: LOGIN AS TENANT 101 (ACME CORP)
-- ----------------------------------------------------------------------------
INSERT OR REPLACE INTO active_session_context VALUES ('SESSION_CURRENT', 101, 'TENANT_USER');

-- Query through RLS without any manual WHERE clause:
SELECT 
    'TENANT_101_VIEW' AS simulation_context,
    doc_id,
    company_name,
    document_title,
    classification,
    file_size_kb || ' KB' AS file_size
FROM rls_tenant_documents;

-- ----------------------------------------------------------------------------
-- 4. TEST 2: SWITCH CONTEXT TO TENANT 102 (STARLIGHT LOGISTICS)
-- ----------------------------------------------------------------------------
UPDATE active_session_context 
SET active_tenant_id = 102, 
    active_user_role = 'TENANT_USER'
WHERE session_id = 'SESSION_CURRENT';

SELECT 
    'TENANT_102_VIEW' AS simulation_context,
    doc_id,
    company_name,
    document_title,
    classification,
    file_size_kb || ' KB' AS file_size
FROM rls_tenant_documents;

-- ----------------------------------------------------------------------------
-- 5. TEST 3: SUPER ADMIN BYPASS POLICY AUDIT
-- ----------------------------------------------------------------------------
-- Platform Operations Admin needs cross-tenant visibility for system backup & audit:
UPDATE active_session_context 
SET active_tenant_id = 101, 
    active_user_role = 'SUPER_ADMIN'
WHERE session_id = 'SESSION_CURRENT';

SELECT 
    'SUPER_ADMIN_CROSS_TENANT_AUDIT' AS audit_context,
    COUNT(*) AS total_documents_visible,
    COUNT(DISTINCT tenant_id) AS distinct_tenants_audited,
    SUM(file_size_kb) || ' KB' AS aggregate_storage_footprint
FROM rls_tenant_documents;
