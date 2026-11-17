# CP3 – Query Optimization Report

## 1. Objective

This report evaluates query optimization through indexing and SQL rewrites for the Housing database workload.

## 2. Optimization techniques

- Added 18 indexes for frequently filtered, joined, and ordered columns.
- Added partial indexes for active rental and sale property searches.
- Added composite indexes for owner, project, enquiry, and site-visit lookups.
- Added date-oriented indexes for listing, enquiry, price-change, and visit queries.
- Rewrote R19 to replace two correlated subqueries with one LEFT JOIN and grouped aggregation.

## 3. Benchmark methodology

- Database: PostgreSQL
- Database name: housing_db
- Baseline workload: queries/workload_30.sql
- Optimized workload: sql/06_optimized_queries.sql
- Benchmark repetitions: 3 runs per query
- Reported timing: average execution time in milliseconds

## 4. Query-wise performance comparison

| Query | Type | Baseline avg (ms) | Optimized avg (ms) | Change | Speedup |
|---|---|---:|---:|---:|---:|
| R01 | READ | 13.072 | 0.159 | 98.8% faster | 82.21x |
| R02 | READ | 8.862 | 0.391 | 95.6% faster | 22.66x |
| R03 | READ | 0.365 | 0.104 | 71.5% faster | 3.51x |
| R04 | READ | 12.549 | 0.805 | 93.6% faster | 15.59x |
| R05 | READ | 7.289 | 2.462 | 66.2% faster | 2.96x |
| R06 | READ | 10.848 | 1.417 | 86.9% faster | 7.66x |
| R07 | READ | 2.242 | 0.474 | 78.9% faster | 4.73x |
| R08 | READ | 1.477 | 5.715 | 286.9% slower | 0.26x |
| R09 | READ | 10.858 | 2.605 | 76.0% faster | 4.17x |
| R10 | READ | 0.050 | 0.049 | 2.0% faster | 1.02x |
| R11 | READ | 8.483 | 0.250 | 97.1% faster | 33.93x |
| R12 | READ | 7.410 | 4.949 | 33.2% faster | 1.50x |
| R13 | READ | 10.927 | 10.676 | 2.3% faster | 1.02x |
| R14 | READ | 13.639 | 7.191 | 47.3% faster | 1.90x |
| R15 | READ | 10.853 | 10.898 | Within ±1% | 1.00x |
| R16 | READ | 0.475 | 0.469 | 1.3% faster | 1.01x |
| R17 | READ | 19.792 | 12.472 | 37.0% faster | 1.59x |
| R18 | READ | 15.607 | 10.433 | 33.2% faster | 1.50x |
| R19 | READ | 8847.716 | 8.062 | 99.9% faster | 1097.46x |
| R20 | READ | 13.054 | 4.558 | 65.1% faster | 2.86x |
| R21 | READ | 10.014 | 10.332 | 3.2% slower | 0.97x |
| R22 | READ | 29.180 | 6.096 | 79.1% faster | 4.79x |
| R23 | READ | 1.332 | 0.123 | 90.8% faster | 10.83x |
| R24 | READ | 0.160 | 0.147 | 8.1% faster | 1.09x |
| R25 | READ | 31.690 | 66.195 | 108.9% slower | 0.48x |
| W01 | WRITE | 0.488 | 1.137 | 133.0% slower | 0.43x |
| W02 | WRITE | 0.595 | 0.501 | 15.8% faster | 1.19x |
| W03 | WRITE | 0.462 | 1.016 | 119.9% slower | 0.45x |
| W04 | WRITE | 97.681 | 345.541 | 253.7% slower | 0.28x |
| W05 | WRITE | 8.462 | 0.274 | 96.8% faster | 30.88x |

## 5. Performance observations

- Queries faster by more than 1%: 23
- Queries slower by more than 1%: 6
- Queries within ±1%: 1

### Notable improvements

- **R19:** 99.9% faster.
- **R01:** 98.8% faster.
- **R11:** 97.1% faster.
- **W05:** 96.8% faster.
- **R02:** 95.6% faster.
- **R04:** 93.6% faster.
- **R23:** 90.8% faster.
- **R06:** 86.9% faster.

### Regressions to investigate

- **R08:** 286.9% slower than baseline.
- **W04:** 253.7% slower than baseline.
- **W01:** 133.0% slower than baseline.
- **W03:** 119.9% slower than baseline.
- **R25:** 108.9% slower than baseline.
- **R21:** 3.2% slower than baseline.

## 6. R19 detailed optimization

The original R19 query calculated enquiry count and latest enquiry date using two separate correlated subqueries for every qualifying property. The baseline execution plan shows each subquery performing a sequential scan of the enquiries table 1,780 times.

The optimized query uses a LEFT JOIN to enquiries and groups by property, calculating COUNT(enquiry_id) and MAX(created_at) together.

- Baseline average: 8847.716 ms
- Optimized average: 8.062 ms
- Approximate speedup: 1097.5x
- Result equivalence: verified using EXCEPT ALL in both directions; both mismatch counts were zero.

## 7. Index observations

The optimized plans show index usage for several selective searches, including R01, R02, R04, R06, R07, R08, R09, R11, R19, R20, R22, and R23. The planner still selects sequential scans for some queries where it estimates that scanning the table is cheaper.

## 8. Conclusion and future work

Indexing and SQL rewriting improved several workload queries substantially. R19 demonstrates the benefit of eliminating repeated correlated scans. Some queries regressed, particularly where added indexes may increase write overhead or where the planner chooses a different access path. Further work should investigate R05, R08, R12, R13, R15, R17, R21, R25, and write-heavy W04 using query-specific plans and larger datasets.

All performance figures are measurements from the supplied benchmark runs and may vary with cache state and machine load.
