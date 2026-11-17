# CP4 – Scalability and Large Dataset Readiness Report

**Project:** Housing Database Management System
**Database:** PostgreSQL – `housing_db`
**Report status:** Seed-data evidence completed; faculty large dataset benchmark pending.

## 1. Objective

This report documents current seed-database measurements, partitioning proof, storage observations, and the architecture planned for 20x and 100x growth.

**Important:** The faculty-provided `large_data.zip` is expected on 19 November 2026. The measurements below are from the existing seed dataset only. No large-dataset timings or performance-target claims are fabricated.

## 2. Seed database baseline and optimized timings

The following averages are read directly from `benchmarks/results/baseline/summary.csv` and `benchmarks/results/optimized/summary.csv`. All values are milliseconds and represent three benchmark runs.

| Query | Type | Baseline avg (ms) | Optimized avg (ms) | Change |
|---|---|---:|---:|---:|
| R01 | READ | 13.072 | 0.159 | 98.8% faster |
| R02 | READ | 8.862 | 0.391 | 95.6% faster |
| R03 | READ | 0.365 | 0.104 | 71.5% faster |
| R04 | READ | 12.549 | 0.805 | 93.6% faster |
| R05 | READ | 7.289 | 2.462 | 66.2% faster |
| R06 | READ | 10.848 | 1.417 | 86.9% faster |
| R07 | READ | 2.242 | 0.474 | 78.9% faster |
| R08 | READ | 1.477 | 5.715 | 286.9% slower |
| R09 | READ | 10.858 | 2.605 | 76.0% faster |
| R10 | READ | 0.050 | 0.049 | 2.0% faster |
| R11 | READ | 8.483 | 0.250 | 97.1% faster |
| R12 | READ | 7.410 | 4.949 | 33.2% faster |
| R13 | READ | 10.927 | 10.676 | 2.3% faster |
| R14 | READ | 13.639 | 7.191 | 47.3% faster |
| R15 | READ | 10.853 | 10.898 | Within ±1% |
| R16 | READ | 0.475 | 0.469 | 1.3% faster |
| R17 | READ | 19.792 | 12.472 | 37.0% faster |
| R18 | READ | 15.607 | 10.433 | 33.2% faster |
| R19 | READ | 8847.716 | 8.062 | 99.9% faster |
| R20 | READ | 13.054 | 4.558 | 65.1% faster |
| R21 | READ | 10.014 | 10.332 | 3.2% slower |
| R22 | READ | 29.180 | 6.096 | 79.1% faster |
| R23 | READ | 1.332 | 0.123 | 90.8% faster |
| R24 | READ | 0.160 | 0.147 | 8.1% faster |
| R25 | READ | 31.690 | 66.195 | 108.9% slower |
| W01 | WRITE | 0.488 | 1.137 | 133.0% slower |
| W02 | WRITE | 0.595 | 0.501 | 15.8% faster |
| W03 | WRITE | 0.462 | 1.016 | 119.9% slower |
| W04 | WRITE | 97.681 | 345.541 | 253.7% slower |
| W05 | WRITE | 8.462 | 0.274 | 96.8% faster |

These timings are seed-data measurements and are not substitutes for the required 20x large-dataset benchmark.

## 3. Seed database storage observations

| Metric | Measured value |
|---|---:|
| Total database size | 128 MB |
| Properties total relation size | 51 MB |
| Properties table heap | 19 MB |
| Properties indexes | 33 MB |
| Enquiries total relation size | 15 MB |
| Enquiries table heap | 7,232 kB |
| Enquiries indexes | 8,472 kB |

The properties indexes occupy more space than the properties heap in this seed database. At larger scale, index storage, cache residency, vacuum work, and write amplification must be monitored. Indexes should be retained only when their read benefit justifies their storage and write cost.

## 4. Partitioning design and evidence

The demonstration uses PostgreSQL declarative RANGE partitioning on `posted_at`, with yearly partitions. It is isolated in the `housing_partition_demo` schema; the original `housing` schema and its foreign keys remain unchanged.

The current source schema has `properties(property_id)` as its primary key, and `price_changes`, `enquiries`, `site_visits`, and `shortlists` reference that key. PostgreSQL requires a partitioned unique or primary key to include the partition key. Therefore, a production RANGE(`posted_at`) migration needs a key redesign.

The demonstration uses:
- A non-partitioned `property_identity` registry with globally unique `property_id`.
- A unique `(property_id, posted_at)` pair in the registry.
- A partitioned table with composite primary key `(property_id, posted_at)`.
- A composite foreign key from the partitioned table to the registry.
- Foreign keys to the existing users, projects, and localities tables.

### 4.1 Partition distribution

| Partition | Rows |
|---|---:|
| `properties_2025` | 80,237 |
| `properties_2026` | 39,823 |
| `properties_default` | 0 |
| **Total** | **120,060** |

The default partition is empty for the current seed dataset. The partition boundaries use India Standard Time (UTC+05:30), matching the timestamps in the source data.

### 4.2 Partition pruning evidence

The executed query filtered `posted_at` between 1 January 2025 and 1 January 2026 (IST). Its `EXPLAIN (COSTS OFF)` output contained:

```text
Seq Scan on properties_2025 properties_partitioned
  Filter: (posted_at >= '2025-01-01 00:00:00+05:30'
       AND posted_at < '2026-01-01 00:00:00+05:30')
```

Only `properties_2025` appeared in the plan. This demonstrates partition pruning for the tested seed-data date range. It does not establish a large-data latency improvement; that must be measured after loading the faculty dataset.

## 5. 20x large dataset benchmark – pending

The faculty dataset is expected on 19 November 2026. After release:

1. Create a separate database for the large dataset.
2. Execute `sql/01_schema.sql`.
3. From the repository root, run `psql -d <large_db_name> -v ON_ERROR_STOP=1 -f sql/03_load_large_data.sql` to load the supplied `large_data/` CSV files. Do not commit the large CSV data to Git.
4. Execute `sql/05_indexes.sql` and run `ANALYZE`.
5. Execute the optimized workload `sql/06_optimized_queries.sql`.
6. Run three benchmark repetitions and preserve every raw plan under `benchmarks/results/large/`.
7. Record all 30 average timings in `benchmarks/results/large/summary.csv`.
8. Compare the measured results against the faculty targets below.

### 5.1 Required performance targets

| Workload class | Query IDs | Target |
|---|---|---:|
| Real-time / user-facing | R01, R02, R03, R05, R06, R07, R10, R11, R23, W01, W02, W03, W05 | < 5 ms |
| Interactive tools | R08, R09, R12, R13, R16, R17, R22, R24 | < 250 ms |
| Analytics | R04, R14, R15, R18, R19, R20, R21, R25 | < 5,000 ms |
| Batch | W04 | < 1,000 ms |

**Status:** Not yet measured on the faculty large dataset. Target compliance is therefore pending.

## 6. Scale-only risks and mitigation plan

| Risk at scale | Mitigation / validation |
|---|---|
| Large property and enquiry scans | Use selective indexes, inspect `EXPLAIN (ANALYZE, BUFFERS)`, and consider partition pruning for date-scoped workloads. |
| Index storage and write amplification | Measure index sizes and write latency; remove only proven redundant indexes after plan and workload validation. |
| Skewed locality or city distribution | Inspect cardinality and query plans; consider targeted composite indexes or partitioning only where workload evidence supports it. |
| Growing write contention | Batch bulk loads, keep transactions bounded, and evaluate connection pooling and write-path separation. |
| Stale statistics | Schedule `ANALYZE`; monitor autovacuum and analyze thresholds on high-churn tables. |
| Historical data growth | Consider archival policies and summary tables for historical analytics after validating retention requirements. |
| Read traffic growth | Add read replicas for eligible read-only workloads; monitor replication lag and route writes to the primary. |

## 7. 100x architecture proposal

The following is a proposed architecture, not an implemented or benchmarked deployment.

### 7.1 Partitioning

Use RANGE(`posted_at`) for property history and time-based queries where partition pruning is useful. Create future partitions ahead of time and retain a DEFAULT partition with monitoring so unexpected dates do not fail inserts. Keep the global identity registry non-partitioned if globally unique property IDs are required. Child-table relationships must reference the registry or carry the partition key and reference a valid composite key.

### 7.2 Sharding

If a single PostgreSQL primary reaches its write or storage limits, evaluate horizontal sharding by a stable tenant, region, or city key. Route reads and writes consistently, define cross-shard query behavior, and avoid assuming that partitioning across one server is the same as sharding across servers.

### 7.3 Read replicas and caching

Use read replicas for reporting and read-heavy traffic where slightly stale data is acceptable. Use a cache for frequently requested property summaries and locality metadata, with explicit TTLs and invalidation on property updates. Keep authoritative writes on the primary and account for replica lag.

### 7.4 Maintenance and analytics

- Monitor autovacuum, dead tuples, table bloat, replication lag, and disk growth.
- Run `ANALYZE` after bulk loads and monitor statistics freshness.
- Plan partition creation, retention, and archival operations.
- Use summary/materialized tables for expensive recurring analytics where freshness requirements permit.
- Track query latency percentiles, buffer reads, index usage, and write overhead.

## 8. Conclusion

The seed database currently occupies 128 MB. A separate RANGE partitioning demonstration successfully loaded all 120,060 properties into yearly partitions and showed pruning to the 2025 partition for a matching date-range query. The existing CP3 benchmark summaries provide seed-data performance evidence.

The 20x benchmark, target compliance, and any scale-specific tuning conclusions remain pending until the faculty dataset is released and measured. The 100x design above is an architecture proposal that must be validated against actual workload and operational measurements.

## 9. Evidence files

- `benchmarks/results/baseline/summary.csv`
- `benchmarks/results/optimized/summary.csv`
- `benchmarks/results/baseline/`
- `benchmarks/results/optimized/`
- `sql/08_partitioning.sql`
