# CP4 – Scalability and Large Dataset Readiness Report

**Project:** Housing Database Management System
**Database:** PostgreSQL – `housing_db`
**Report status:** Seed-data evidence completed; faculty large dataset loaded and benchmarked. Actual performance results and target compliance documented below.

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

## 5. Large dataset benchmark – completed

The faculty-provided large dataset was downloaded, extracted, and loaded into a separate PostgreSQL database named `codenova_phase5`. The original database was left unchanged.

### 5.1 Dataset loading evidence

The dataset contains 12 CSV files and **7,932,194 data rows** in total.

| Table | Loaded rows |
|---|---:|
| cities | 10 |
| localities | 100 |
| builders | 150 |
| projects | 24,000 |
| amenities | 15 |
| project_amenities | 135,921 |
| users | 800,000 |
| properties | 2,401,264 |
| price_changes | 470,019 |
| enquiries | 2,000,000 |
| site_visits | 699,415 |
| shortlists | 1,400,000 |
| **Total** | **7,932,194** |

All 12 tables loaded successfully using `sql/03_load_large_data.sql`. The script completed with `ANALYZE`, and the loaded row counts were verified.

The performance indexes were then created successfully using `sql/05_indexes.sql`. The housing schema contains 32 indexes, including primary-key/unique indexes and the 18 performance indexes defined by the project.

### 5.2 Benchmark methodology

The optimized workload in `sql/06_optimized_queries.sql` was executed against `codenova_phase5` using three benchmark repetitions per query.

Command:

```bash
./benchmarks/run_benchmark.sh codenova_phase5 large 3 sql/06_optimized_queries.sql
```

The benchmark covered 25 read queries (R01–R25) and 5 write queries (W01–W05). Average, median, minimum, and maximum execution times were recorded in milliseconds.

The benchmark generated 30 raw query-plan files and the measured summary:

- `benchmarks/results/large/summary.csv`
- `benchmarks/results/large/R01.txt` through `R25.txt`
- `benchmarks/results/large/W01.txt` through `W05.txt`

The original estimates were preserved separately in `benchmarks/results/large/projected_summary.csv`. Projected values are estimates, not measured results.

### 5.3 Actual large dataset benchmark results

All timings below are actual averages from the three benchmark repetitions.

| Query | Type | Actual average (ms) | Target (ms) | Result |
|---|---|---:|---:|---|
| R01 | READ | 2.339 | < 5 | PASS |
| R02 | READ | 4.472 | < 5 | PASS |
| R03 | READ | 0.395 | < 5 | PASS |
| R04 | READ | 22.408 | < 5,000 | PASS |
| R05 | READ | 7.120 | < 5 | FAIL |
| R06 | READ | 1.131 | < 5 | PASS |
| R07 | READ | 0.460 | < 5 | PASS |
| R08 | READ | 24.944 | < 250 | PASS |
| R09 | READ | 102.300 | < 250 | PASS |
| R10 | READ | 0.317 | < 5 | PASS |
| R11 | READ | 0.266 | < 5 | PASS |
| R12 | READ | 136.566 | < 250 | PASS |
| R13 | READ | 759,891.575 | < 250 | FAIL |
| R14 | READ | 125.495 | < 5,000 | PASS |
| R15 | READ | 163.814 | < 5,000 | PASS |
| R16 | READ | 16.877 | < 250 | PASS |
| R17 | READ | 340.870 | < 250 | FAIL |
| R18 | READ | 946.856 | < 5,000 | PASS |
| R19 | READ | 177.102 | < 5,000 | PASS |
| R20 | READ | 113.475 | < 5,000 | PASS |
| R21 | READ | 303.655 | < 5,000 | PASS |
| R22 | READ | 12.849 | < 250 | PASS |
| R23 | READ | 0.200 | < 5 | PASS |
| R24 | READ | 2.691 | < 250 | PASS |
| R25 | READ | 5,135.005 | < 5,000 | FAIL |
| W01 | WRITE | 2.057 | < 5 | PASS |
| W02 | WRITE | 1.061 | < 5 | PASS |
| W03 | WRITE | 1.950 | < 5 | PASS |
| W04 | WRITE | 35,423.401 | < 1,000 | FAIL |
| W05 | WRITE | 0.785 | < 5 | PASS |

**Overall result: 25 of 30 queries meet their specified targets. Five queries exceed their targets: R05, R13, R17, R25, and W04.**

### 5.4 Projected versus actual performance

The original projected measurements were estimates based on optimized seed-data timings and expected growth factors. The actual large-dataset benchmark shows that some queries scale less effectively than expected.

| Query | Projected (ms) | Actual (ms) | Observation |
|---|---:|---:|---|
| R05 | 4.185 | 7.120 | Slightly exceeds the 5 ms target |
| R13 | 213.520 | 759,891.575 | Extremely large regression |
| R17 | 249.440 | 340.870 | Exceeds the 250 ms target |
| R25 | 1,323.900 | 5,135.005 | Slightly exceeds the 5,000 ms target |
| W04 | 6,910.820 | 35,423.401 | Bulk update is substantially slower than projected |

The remaining 25 queries meet their specified performance targets.

### 5.5 Bottleneck analysis

**R13 – project/property exclusion query**

R13 is the most significant bottleneck, averaging approximately 759.9 seconds (12.7 minutes). Its recorded plan includes sequential scans on both `projects` and `properties`. This indicates that the query performs expensive work over large relations. The query and its execution plan should be investigated before selecting a rewrite or additional index.

**W04 – bulk property update**

W04 averages approximately 35.4 seconds, substantially exceeding its 1,000 ms target. Its plan uses `idx_properties_active_posted_at`, but locating rows through an index does not eliminate the cost of updating a large number of qualifying rows. Batching the update and measuring the batches separately is a potential optimization.

**R25 – shortlist/property analytical query**

R25 averages approximately 5.14 seconds, slightly above its 5-second target. Its plan includes sequential scans on `shortlists`, `properties`, and `localities`. The query's join and filtering strategy should be examined for opportunities to reduce the number of rows processed.

**R17 – enquiry-related query**

R17 averages approximately 341 ms, above its 250 ms target. Its plan includes a sequential scan on `enquiries` and an index scan on `properties`. Further examination of its predicates, join cardinality, and index selectivity is warranted.

**R05 – active listing query**

R05 averages approximately 7.12 ms, modestly above its 5 ms target. Its plan uses `idx_properties_active_posted_at`, so the existing index is being considered by the planner. Further optimization should be based on the complete execution plan and buffer statistics.

### 5.6 Large dataset benchmark conclusion

The large dataset was successfully loaded and benchmarked, and all 30 workload queries produced measured results and raw execution plans.

The results demonstrate that the existing indexes support fast execution for most user-facing and interactive queries. However, R13, W04, R25, R17, and R05 require additional investigation or optimization.

The measured results replace the earlier projections as the actual Phase 5 performance evidence. No claim is made that all performance targets have been achieved.


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

The project successfully completed the large dataset loading and benchmarking phase using a separate PostgreSQL database, `codenova_phase5`.

The faculty dataset contained 7,932,194 rows across 12 tables. All rows were loaded and verified, the performance indexes were created, and the 30-query optimized workload was benchmarked with three repetitions per query.

The seed-data benchmarks demonstrated substantial improvements for several queries after indexing and query optimization. The large dataset benchmark provides additional evidence of how the database behaves under significantly higher data volumes.

Of the 30 measured workload queries, 25 met their specified performance targets. Five queries—R05, R13, R17, R25, and W04—exceeded their targets. R13 and W04 were the most significant bottlenecks and require further optimization.

The separate RANGE partitioning demonstration successfully showed partition pruning for the tested date range. The proposed 100x architecture, including partitioning, sharding, read replicas, caching, and maintenance strategies, remains a design proposal rather than a deployed system.

Overall, the project demonstrates successful large-scale data loading, indexing, execution-plan analysis, performance measurement, and identification of scalability bottlenecks. The measured results provide a foundation for further optimization.

## 9. Evidence files

- `benchmarks/results/baseline/summary.csv`
- `benchmarks/results/optimized/summary.csv`
- `benchmarks/results/baseline/`
- `benchmarks/results/optimized/`
- `sql/08_partitioning.sql`
- `sql/03_load_large_data.sql`
- `sql/05_indexes.sql`
- `sql/06_optimized_queries.sql`
- `benchmarks/results/large/summary.csv`
- `benchmarks/results/large/projected_summary.csv`
- `benchmarks/results/large/` (30 raw execution plans)