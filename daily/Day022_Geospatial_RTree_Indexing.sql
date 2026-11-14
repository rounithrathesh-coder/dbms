-- ============================================================================
-- Daily DBMS Challenge - Day 022 (2026-11-14)
-- Topic: Spatial Indexing - R-Trees, Geohashes & Haversine Proximity Searches
-- Category: Spatial GIS & Multidimensional Indexing
-- RDBMS Compatibility: SQLite (rtree extension), PostgreSQL (PostGIS), MySQL 8.0+
-- ============================================================================

-- Standard B-Tree indexes struggle with 2D spatial queries. A composite index
-- on (latitude, longitude) can only efficiently prune the leading column (latitude);
-- the database must still evaluate or scan all matching longitude candidates.
--
-- R-TREES (Rectangle Trees) solve this by hierarchically nesting Minimum Bounding
-- Boxes (MBRs). A search for points inside a bounding box prunes non-intersecting
-- branches in O(log N) time across both spatial dimensions simultaneously.

.headers on
.mode box

-- ----------------------------------------------------------------------------
-- 1. BASE BUSINESS TABLE & R*TREE VIRTUAL INDEX TABLE
-- ----------------------------------------------------------------------------
DROP TABLE IF EXISTS venues_index;
DROP TABLE IF EXISTS venues;

CREATE TABLE venues (
    venue_id INTEGER PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    category VARCHAR(50) NOT NULL,
    rating NUMERIC(2, 1) NOT NULL,
    latitude REAL NOT NULL,
    longitude REAL NOT NULL
);

-- SQLite R*Tree Virtual Index: (id, min_lon, max_lon, min_lat, max_lat)
-- For points, min_val equals max_val.
CREATE VIRTUAL TABLE venues_index USING rtree(
    id,
    min_lon, max_lon,
    min_lat, max_lat
);

-- Triggers to maintain R*Tree synchronization with base table
CREATE TRIGGER trg_venues_insert AFTER INSERT ON venues
BEGIN
    INSERT INTO venues_index (id, min_lon, max_lon, min_lat, max_lat)
    VALUES (NEW.venue_id, NEW.longitude, NEW.longitude, NEW.latitude, NEW.latitude);
END;

CREATE TRIGGER trg_venues_delete AFTER DELETE ON venues
BEGIN
    DELETE FROM venues_index WHERE id = OLD.venue_id;
END;

-- ----------------------------------------------------------------------------
-- 2. SEED VENUE LOCATIONS (CHENNAI METROPOLITAN CLUSTER)
-- ----------------------------------------------------------------------------
INSERT INTO venues VALUES
(1, 'Tidel Park Tech Center', 'IT Hub',        4.8, 12.9893, 80.2482),
(2, 'OMR Ascendas Tech Park',  'IT Hub',        4.7, 12.9345, 80.2312),
(3, 'T. Nagar Commercial Hub', 'Retail/Dining', 4.5, 13.0418, 80.2341),
(4, 'Marina Promenade',        'Tourism',       4.6, 13.0500, 80.2824),
(5, 'Chennai Central Gateway', 'Transit Hub',   4.4, 13.0827, 80.2707),
(6, 'International Airport',   'Airport',       4.3, 12.9863, 80.1662),
(7, 'SIPCOT Siruseri IT Park', 'IT Hub',        4.6, 12.8250, 80.2200),
(8, 'Guindy Industrial Estate','Commercial',    4.5, 13.0067, 80.2025);

-- ----------------------------------------------------------------------------
-- 3. QUERY 1: BOUNDING BOX WINDOW SEARCH VIA R*TREE
-- ----------------------------------------------------------------------------
-- Fast spatial filtering: Find all venues within a target rectangular bounding box:
-- Longitude: [80.20, 80.26], Latitude: [12.95, 13.05]
SELECT 
    v.venue_id,
    v.name,
    v.category,
    v.rating,
    v.latitude,
    v.longitude
FROM venues_index r
JOIN venues v ON r.id = v.venue_id
WHERE r.min_lon >= 80.20 AND r.max_lon <= 80.26
  AND r.min_lat >= 12.95 AND r.max_lat <= 13.05
ORDER BY v.rating DESC;

-- ----------------------------------------------------------------------------
-- 4. QUERY 2: PROXIMITY RADIUS SEARCH WITH GREAT-CIRCLE DISTANCE (FROM TIDEL PARK)
-- ----------------------------------------------------------------------------
-- Origin: Tidel Park (Lat: 12.9893, Lon: 80.2482)
-- Spherical flat-Earth approximation (valid for distances < 50 km):
-- 1 deg Latitude  ~ 110.574 km
-- 1 deg Longitude ~ 111.320 * cos(lat) ~ 108.48 km (at 13 deg N)
WITH DistanceCalculations AS (
    SELECT 
        v.venue_id,
        v.name,
        v.category,
        v.rating,
        v.latitude,
        v.longitude,
        ROUND(
            SQRT(
                POW((v.latitude - 12.9893) * 110.574, 2) +
                POW((v.longitude - 80.2482) * 108.480, 2)
            ), 2
        ) AS distance_km
    FROM venues v
)
SELECT 
    name,
    category,
    rating,
    distance_km || ' km' AS distance_from_tidel
FROM DistanceCalculations
WHERE distance_km <= 10.0
ORDER BY distance_km ASC;

-- ----------------------------------------------------------------------------
-- 5. QUERY 3: CATEGORY AGGREGATION & SPATIAL DENSITY SUMMARY
-- ----------------------------------------------------------------------------
SELECT 
    category,
    COUNT(*) AS total_venues,
    ROUND(AVG(rating), 2) AS avg_rating,
    ROUND(MIN(latitude), 4) || ' to ' || ROUND(MAX(latitude), 4) AS lat_span,
    ROUND(MIN(longitude), 4) || ' to ' || ROUND(MAX(longitude), 4) AS lon_span
FROM venues
GROUP BY category
ORDER BY total_venues DESC;
