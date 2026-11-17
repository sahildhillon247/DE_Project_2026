-- ============================================================
-- CP4: Property table partitioning demonstration
-- Strategy: RANGE partitioning on posted_at
-- Original housing schema remains unchanged.
-- ============================================================

-- Dedicated schema keeps this experiment isolated.
DROP SCHEMA IF EXISTS housing_partition_demo CASCADE;
CREATE SCHEMA housing_partition_demo;

-- Global property ID registry.
-- Child tables in a production migration can reference this table.
CREATE TABLE housing_partition_demo.property_identity (
    property_id INT PRIMARY KEY,
    posted_at TIMESTAMPTZ NOT NULL,
    UNIQUE (property_id, posted_at)
);

INSERT INTO housing_partition_demo.property_identity (property_id, posted_at)
SELECT property_id, posted_at
FROM housing.properties;

-- Copy the original property columns and CHECK constraints.
-- The original single-column PK is intentionally not copied.
CREATE TABLE housing_partition_demo.properties_partitioned
(
    LIKE housing.properties INCLUDING DEFAULTS INCLUDING CONSTRAINTS
)
PARTITION BY RANGE (posted_at);

-- A partitioned unique/primary key must include the partition key.
ALTER TABLE housing_partition_demo.properties_partitioned
ADD CONSTRAINT properties_partitioned_pk
PRIMARY KEY (property_id, posted_at);

-- Preserve global property ID ownership through the registry.
ALTER TABLE housing_partition_demo.properties_partitioned
ADD CONSTRAINT properties_partitioned_identity_fk
FOREIGN KEY (property_id, posted_at)
REFERENCES housing_partition_demo.property_identity(property_id, posted_at);

-- Preserve the other original relationships.
ALTER TABLE housing_partition_demo.properties_partitioned
ADD CONSTRAINT properties_partitioned_user_fk
FOREIGN KEY (listed_by) REFERENCES housing.users(user_id);

ALTER TABLE housing_partition_demo.properties_partitioned
ADD CONSTRAINT properties_partitioned_project_fk
FOREIGN KEY (project_id) REFERENCES housing.projects(project_id);

ALTER TABLE housing_partition_demo.properties_partitioned
ADD CONSTRAINT properties_partitioned_locality_fk
FOREIGN KEY (locality_id) REFERENCES housing.localities(locality_id);

-- Year-based range partitions.
CREATE TABLE housing_partition_demo.properties_2025
PARTITION OF housing_partition_demo.properties_partitioned
FOR VALUES FROM ('2024-12-31 18:30:00+00')
             TO ('2025-12-31 18:30:00+00');

CREATE TABLE housing_partition_demo.properties_2026
PARTITION OF housing_partition_demo.properties_partitioned
FOR VALUES FROM ('2025-12-31 18:30:00+00')
             TO ('2026-12-31 18:30:00+00');

-- Catch dates outside the defined ranges and NULL posted_at values.
CREATE TABLE housing_partition_demo.properties_default
PARTITION OF housing_partition_demo.properties_partitioned
DEFAULT;

-- Copy seed properties into the demonstration table.
INSERT INTO housing_partition_demo.properties_partitioned
SELECT *
FROM housing.properties;

ANALYZE housing_partition_demo.properties_partitioned;

-- Verify distribution across partitions.
SELECT
    tableoid::regclass AS partition_name,
    COUNT(*) AS property_count
FROM housing_partition_demo.properties_partitioned
GROUP BY tableoid
ORDER BY tableoid::regclass::text;

-- Demonstrate partition pruning for a date-range query.
EXPLAIN (COSTS OFF)
SELECT property_id, price, posted_at
FROM housing_partition_demo.properties_partitioned
WHERE posted_at >= TIMESTAMPTZ '2025-01-01 00:00:00+05:30'
  AND posted_at <  TIMESTAMPTZ '2026-01-01 00:00:00+05:30';

-- Design note:
-- Existing child tables currently reference properties(property_id).
-- In a RANGE(posted_at) production migration, their references should
-- be redesigned to reference property_identity(property_id), or they
-- must carry posted_at and reference the composite key.
-- The original housing tables are deliberately not altered here.
