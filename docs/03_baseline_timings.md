# Baseline Query Performance Report

## 1. Project Overview

**Project:** Housing.com Property Search Database  
**Checkpoint:** CP2 – Baseline Performance Measurement  
**Database:** PostgreSQL (`housing_db`)  
**Schema:** `housing`  
**Workload:** 30 queries (25 read queries and 5 write queries)  
**Runs per query:** 3

This report documents the baseline performance of the Housing.com Property Search database before applying query optimization and additional indexes.

## 2. Benchmark Methodology

The benchmark was executed using:

```bash
./benchmarks/run_benchmark.sh housing_db baseline 3
```

The benchmark process:

1. Executes all 30 queries from `queries/workload_30.sql`.
2. Runs each query three times.
3. Uses `EXPLAIN (ANALYZE, BUFFERS)` to collect execution plans and actual execution times.
4. Calculates average, median, minimum and maximum execution times.
5. Saves individual execution plans as text files.
6. Stores aggregated results in `benchmarks/results/baseline/summary.csv`.

Write queries are executed inside transactions and rolled back to prevent permanent changes to the database during benchmarking.

All execution times in this report are in milliseconds (ms).

## 3. Read Query Results

| ID | Query Description | Run 1 | Run 2 | Run 3 | Average |
|---|---|---:|---:|---:|---:|
| R01 | Active 2 BHK rentals in Koramangala under ₹40,000 | 16.273 | 12.291 | 10.651 | 13.072 |
| R02 | 3 BHK apartments for sale in Pune under ₹1.2 crore | 9.767 | 8.791 | 8.028 | 8.862 |
| R03 | Property 6897 with project, builder and amenities | 0.919 | 0.089 | 0.086 | 0.365 |
| R04 | Monthly average sale price per sq ft in Whitefield | 13.426 | 12.075 | 12.145 | 12.549 |
| R05 | Active rentals inside central Bengaluru map area | 7.152 | 8.385 | 6.331 | 7.289 |
| R06 | Owner 1033 listings with enquiry and site-visit counts | 11.477 | 10.556 | 10.511 | 10.848 |
| R07 | Site visits on 1 July 2026 for user 4723's listings | 2.317 | 2.216 | 2.192 | 2.242 |
| R08 | Active properties with a price drop of at least 10% in June | 1.611 | 1.436 | 1.385 | 1.477 |
| R09 | Active properties in projects with gym, pool and power backup | 11.132 | 10.671 | 10.771 | 10.858 |
| R10 | Project lookup by RERA registration ID | 0.051 | 0.051 | 0.048 | 0.050 |
| R11 | Available listings in project 217 grouped by BHK | 8.918 | 8.058 | 8.474 | 8.483 |
| R12 | June enquiries without a matching site visit | 7.621 | 7.392 | 7.218 | 7.410 |
| R13 | Projects with no property listed on Housing.com | 11.760 | 10.367 | 10.655 | 10.927 |
| R14 | Agents ranked by properties sold or rented in 2026 | 14.069 | 13.407 | 13.442 | 13.639 |
| R15 | Rental yield by Bengaluru locality | 10.876 | 10.603 | 11.079 | 10.853 |
| R16 | Projects with "greens" in their name | 0.456 | 0.473 | 0.495 | 0.475 |
| R17 | Active listings older than 90 days with no enquiries | 20.003 | 19.672 | 19.702 | 19.792 |
| R18 | Duplicate flat listings by the same lister | 15.535 | 15.961 | 15.325 | 15.607 |
| R19 | Bengaluru active sale properties with enquiry counts and latest enquiry | 8987.976 | 8771.966 | 8783.206 | 8847.716 |
| R20 | Daily new listings and running total in June 2026 | 13.578 | 13.376 | 12.207 | 13.054 |
| R21 | Average site-visit rating by locality | 9.913 | 10.295 | 9.835 | 10.014 |
| R22 | Listing moderation: page 2,001 with 25 listings | 29.780 | 28.688 | 29.071 | 29.180 |
| R23 | User sign-in by mobile number | 1.342 | 1.321 | 1.333 | 1.332 |
| R24 | Under-construction projects past promised possession date | 0.166 | 0.160 | 0.154 | 0.160 |
| R25 | Shortlists converted into enquiries, grouped by city | 31.985 | 31.012 | 32.072 | 31.690 |

## 4. Write Query Results

| ID | Query Description | Run 1 | Run 2 | Run 3 | Average |
|---|---|---:|---:|---:|---:|
| W01 | Owner 1033 posts a 2 BHK rental in Koramangala | 0.525 | 0.458 | 0.480 | 0.488 |
| W02 | Owner 1033 reduces the rent of their latest active rental by 5% | 0.738 | 0.538 | 0.509 | 0.595 |
| W03 | Seeker 1042 books a visit to property 6897 | 0.520 | 0.435 | 0.432 | 0.462 |
| W04 | Deactivate active listings older than 120 days | 174.406 | 60.581 | 58.055 | 97.681 |
| W05 | Owner 1033 marks their oldest active rental as rented | 9.735 | 8.084 | 7.567 | 8.462 |

## 5. Performance Analysis

### 5.1 Slowest Read Queries

| Query | Average Execution Time |
|---|---:|
| R19 | 8847.716 ms |
| R25 | 31.690 ms |
| R22 | 29.180 ms |
| R17 | 19.792 ms |
| R18 | 15.607 ms |

R19 is the most significant performance bottleneck, with an average execution time of approximately 8.85 seconds.

### 5.2 Fastest Read Queries

| Query | Average Execution Time |
|---|---:|
| R10 | 0.050 ms |
| R24 | 0.160 ms |
| R03 | 0.365 ms |
| R16 | 0.475 ms |
| R23 | 1.332 ms |

R10 benefits from the existing unique index on the RERA registration ID. R03 uses primary-key and index-only scans to retrieve related records efficiently.

### 5.3 Write Query Analysis

W04 is the slowest write query, with an average execution time of 97.681 ms.

It deactivates active listings older than 120 days and performs a sequential scan on the properties table. Its execution time also varies considerably across the three runs.

The other write queries have comparatively low average execution times.

## 6. Detailed Analysis of R19

R19 retrieves enquiry counts and the latest enquiry for every active sale property in Bengaluru.

The execution plan shows:

- A sequential scan on the properties table.
- A sequential scan on the localities table.
- A hash join between properties and localities.
- Two correlated subqueries that repeatedly scan the enquiries table.
- Approximately 1,780 executions of each correlated subplan.

Each correlated subquery scans the enquiries table for the current property. Repeating these scans creates substantial work.

The execution plan reports approximately 1,609,120 shared buffer hits for each of the two enquiry subplans. These are buffer-cache hits, not necessarily physical disk reads.

### Optimization Opportunities

1. Create an index on `enquiries(property_id)` to support property-based enquiry lookups.
2. Replace repeated correlated subqueries with grouped aggregation or a pre-aggregated result.
3. Calculate enquiry counts and latest enquiry information together where possible.
4. Compare the optimized execution plan and timing against the baseline.

The optimized query should be checked for identical results before comparing performance.

## 7. Sequential Scans and Index Usage

The baseline execution plans show a mixture of sequential scans, index scans and index-only scans.

Sequential scans appear frequently on the properties, enquiries and localities tables. These scans can become expensive when queries process a large number of rows.

However, a sequential scan is not automatically inefficient. For small tables such as builders or projects, scanning the entire table may be faster than using an index.

Some queries already benefit from existing indexes:

- R03 uses primary-key and index-only scans.
- R10 uses the unique index on `projects.rera_id`.
- R07 and R08 use indexes for selected lookups.
- R25 uses an index-only scan on shortlists, although other operations in the query also contribute to its execution time.

Index selection should therefore be based on actual query plans and measured performance.

## 8. Baseline Files

The benchmark output is stored in:

```text
benchmarks/results/baseline/
```

It contains:

- `summary.csv` – aggregated timings for all 30 queries.
- `R01.txt` through `R25.txt` – raw execution plans for read queries.
- `W01.txt` through `W05.txt` – raw execution plans for write queries.

The original workload is maintained in:

```text
queries/workload_30.sql
```

## 9. Conclusion

The baseline benchmark establishes the initial performance of the Housing.com Property Search database using 30 representative read and write queries.

R19 is the primary optimization target because its repeated correlated scans of the enquiries table result in an average execution time of approximately 8.85 seconds.

W04 is the slowest write query and is another candidate for investigation.

These baseline measurements will be used as the reference point for evaluating the impact of indexing and query optimization in the next checkpoint.

All reported measurements are from the local PostgreSQL benchmark environment. Results may vary on different hardware and database configurations.
