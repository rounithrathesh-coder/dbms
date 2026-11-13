-- ============================================================================
-- Daily DBMS Challenge - Day 020 (2026-11-13)
-- Topic: Graph Modeling - Adjacency Lists, Shortest Paths & Transitive Closure
-- Category: Graph Queries & Recursive Hierarchies
-- RDBMS Compatibility: PostgreSQL, SQLite, MySQL 8.0+, Oracle
-- ============================================================================

-- Relational databases can effectively model and query directed graphs, dependency
-- trees, and transit networks using Adjacency Lists and Recursive CTEs.
--
-- Key Graph Concepts Demonstrated:
-- 1. Adjacency Table representation with edge weights (latency/cost).
-- 2. Transitive Closure: finding all nodes reachable from a given origin.
-- 3. Cycle Detection: preventing infinite recursion in cyclic graphs.
-- 4. Minimum Cost Path Search across arbitrary network topologies.

.headers on
.mode box

-- ----------------------------------------------------------------------------
-- 1. BASE GRAPH SCHEMA: NODES & WEIGHTED DIRECTED EDGES
-- ----------------------------------------------------------------------------
DROP TABLE IF EXISTS network_edges;
DROP TABLE IF EXISTS network_nodes;

CREATE TABLE network_nodes (
    node_id VARCHAR(10) PRIMARY KEY,
    location_name VARCHAR(100) NOT NULL
);

CREATE TABLE network_edges (
    source_id VARCHAR(10) NOT NULL,
    target_id VARCHAR(10) NOT NULL,
    latency_ms INT NOT NULL CHECK (latency_ms > 0),
    PRIMARY KEY (source_id, target_id),
    FOREIGN KEY (source_id) REFERENCES network_nodes(node_id),
    FOREIGN KEY (target_id) REFERENCES network_nodes(node_id)
);

-- Seed Network Nodes (Datacenters)
INSERT INTO network_nodes VALUES
('SFO', 'San Francisco Gateway'),
('ORD', 'Chicago Transit Hub'),
('JFK', 'New York Financial Node'),
('LHR', 'London Edge Router'),
('FRA', 'Frankfurt Continental Core'),
('SIN', 'Singapore APAC Hub');

-- Seed Directed Weighted Edges
INSERT INTO network_edges VALUES
('SFO', 'ORD', 45),
('SFO', 'SIN', 160),
('ORD', 'JFK', 22),
('JFK', 'LHR', 68),
('LHR', 'FRA', 18),
('ORD', 'FRA', 110),
('FRA', 'SIN', 140),
-- Introduce a back-edge to create a cycle (LHR -> JFK) for cycle-detection validation
('LHR', 'JFK', 68);

-- ----------------------------------------------------------------------------
-- 2. QUERY 1: TRANSITIVE CLOSURE (ALL REACHABLE NODES FROM 'SFO')
-- ----------------------------------------------------------------------------
WITH RECURSIVE ReachableNodes AS (
    -- Anchor: Immediate neighbors of SFO
    SELECT 
        target_id,
        1 AS hops
    FROM network_edges
    WHERE source_id = 'SFO'

    UNION

    -- Recursive step: Traverse downstream neighbors
    SELECT 
        e.target_id,
        r.hops + 1
    FROM ReachableNodes r
    JOIN network_edges e ON r.target_id = e.source_id
    WHERE r.hops < 5 -- Safety recursion depth guard
)
SELECT 
    'SFO' AS origin,
    target_id AS destination,
    MIN(hops) AS min_hops_required
FROM ReachableNodes
GROUP BY target_id
ORDER BY min_hops_required, destination;

-- ----------------------------------------------------------------------------
-- 3. QUERY 2: SHORTEST PATH TRAVERSAL WITH CYCLE DETECTION (SFO -> FRA)
-- ----------------------------------------------------------------------------
WITH RECURSIVE PathFinder AS (
    -- Anchor: Start at 'SFO'
    SELECT 
        source_id,
        target_id,
        latency_ms AS total_latency,
        1 AS total_hops,
        source_id || ' -> ' || target_id AS full_path,
        ',' || source_id || ',' || target_id || ',' AS visited_nodes
    FROM network_edges
    WHERE source_id = 'SFO'

    UNION ALL

    -- Recursive Member: Advance to next hop
    SELECT 
        e.source_id,
        e.target_id,
        p.total_latency + e.latency_ms,
        p.total_hops + 1,
        p.full_path || ' -> ' || e.target_id,
        p.visited_nodes || e.target_id || ','
    FROM PathFinder p
    JOIN network_edges e ON p.target_id = e.source_id
    WHERE INSTR(p.visited_nodes, ',' || e.target_id || ',') = 0 -- CYCLE PREVENTION
      AND p.total_hops < 6
)
SELECT 
    full_path,
    total_hops,
    total_latency || ' ms' AS network_latency
FROM PathFinder
WHERE target_id = 'FRA'
ORDER BY total_latency ASC;
