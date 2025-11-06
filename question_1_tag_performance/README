# 🚀 Stack Overflow Tag & Tag-Pair Performance Analysis (Most Recent Year)

## 🎯 Objective
This analysis answers the following questions:  

- **Single Tags:** Which tags on Stack Overflow questions lead to the most answers and the highest accepted answer rate for the current year? Which tags lead to the least?  
- **Tag Pairs:** How do combinations of tags (co-occurring tags) impact answers and acceptance rates?  

The results provide actionable insights for understanding community engagement around specific topics or topic combinations.

---

## 🛠 Technical Approach

1. **Dynamic Year Detection** – Always uses the most recent year available in the Stack Overflow dataset.  
2. **Data Preprocessing** –  
   - Tags converted to lowercase and split into arrays for consistent aggregation.  
   - Questions without tags are excluded.  
3. **Answer Aggregation** – Total answers per question pre-aggregated for performance.  
4. **Metrics Calculation** – For each tag and tag pair:  
   - `avg_answers_per_question` = total answers ÷ number of questions  
   - `accepted_answer_rate` = accepted answers ÷ number of questions  
   - Only tags/tag pairs with **≥ 10 questions** are included.  
5. **Ranking** – Separate rankings for top and bottom performers based on **accepted answer rate**, with `avg_answers_per_question` as secondary metric.  
6. **Unified Query** – Both single tags and tag pairs processed in one query to reduce scanned data.

---

## 🔍 Data Quality Considerations

| Aspect | Strategy |
|--------|----------|
| **Missing tags** | Excluded to ensure valid `UNNEST()` results |
| **Questions with no answers** | Counted using `LEFT JOIN` |
| **Duplicated tag pairs** | Deduplicated via lexicographical ordering |
| **Year selection** | Dynamically determined from max year |
| **Validation** | Cross-checked counts and averages for consistency |

---

## 🏆 Top Performing Single Tags
| Rank | Tag | Total Questions | Avg Answers | Accepted Rate |
|------|-----|----------------|------------|---------------|
| 1    | conditional-aggregation | 23 | 1.39 | 0.96 |
| 2    | sql-in                  | 22 | 1.27 | 0.91 |
| 3    | usort                   | 11 | 1.18 | 0.91 |
| 3    | moose                   | 11 | 1.18 | 0.91 |
| 3    | select-object           | 11 | 1.18 | 0.91 |
| 6    | malli                   | 11 | 1.00 | 0.91 |
| 7    | jstreer                 | 11 | 0.91 | 0.91 |
| 8    | non-standard-evaluation | 10 | 1.80 | 0.90 |
| 9    | supplier                | 10 | 1.30 | 0.90 |
| 10   | google-query-language   | 277| 1.22 | 0.90 |

### ⚠️ Lowest Performing Single Tags
| Rank | Tag | Total Questions | Avg Answers | Accepted Rate |
|------|-----|----------------|------------|---------------|
| 1    | pyvmomi              | 11 | 0.00 | 0.00 |
| 1    | captiveportal        | 11 | 0.00 | 0.00 |
| 1    | safari-web-inspector | 12 | 0.00 | 0.00 |
| 1    | cloudsim             | 10 | 0.00 | 0.00 |
| 1    | dragula              | 11 | 0.00 | 0.00 |
| 1    | kombu                | 13 | 0.00 | 0.00 |
| 1    | activexobject        | 12 | 0.00 | 0.00 |
| 1    | vagrant-windows      | 10 | 0.00 | 0.00 |
| 1    | lammps               | 10 | 0.00 | 0.00 |
| 1    | google-schemas       | 11 | 0.00 | 0.00 |

---

## 🏆 Top Performing Tag Pairs
| Rank | Tag Pair | Total Questions | Avg Answers | Accepted Rate |
|------|----------|----------------|------------|---------------|
| 1    | common-table-expression | sql-update | 11 | 1.55 | 1.00 |
| 2    | sorting | vlookup | 12 | 1.42 | 1.00 |
| 3    | google-query-language | match | 10 | 1.40 | 1.00 |
| 4    | conditional-aggregation | group-by | 13 | 1.38 | 1.00 |
| 5    | google-sheets-formula | syntax | 11 | 1.36 | 1.00 |
| 5    | sql-order-by | window-functions | 11 | 1.36 | 1.00 |
| 7    | moose | perl | 10 | 1.30 | 1.00 |
| 7    | ggplot2 | purrr | 10 | 1.30 | 1.00 |
| 9    | flatten | transpose | 40 | 1.27 | 1.00 |
| 10   | google-query-language | transpose | 20 | 1.25 | 1.00 |
| 10   | google-query-language | import | 20 | 1.25 | 1.00 |

### ⚠️ Lowest Performing Tag Pairs
| Rank | Tag Pair | Total Questions | Avg Answers | Accepted Rate |
|------|----------|----------------|------------|---------------|
| 1    | attention-model | deep-learning | 16 | 0.00 | 0.00 |
| 1    | flutter | object-detection | 10 | 0.00 | 0.00 |
| 1    | concurrency | php | 10 | 0.00 | 0.00 |
| 1    | fortran | gcc | 10 | 0.00 | 0.00 |
| 1    | api | module | 10 | 0.00 | 0.00 |
| 1    | laravel | ssh | 10 | 0.00 | 0.00 |
| 1    | amazon-kinesis | apache-spark | 11 | 0.00 | 0.00 |
| 1    | chromecast | google-cast-sdk | 11 | 0.00 | 0.00 |
| 1    | next.js | woocommerce | 10 | 0.00 | 0.00 |
| 1    | ssl | swift | 10 | 0.00 | 0.00 |

---

## 🧱 Extendability

This query structure supports:

- Multi-year trends (year-over-year analysis)  
- Dashboard dimensions:
  - `tag_label`, `ranking_scope`, `ranking_type`  
- Metrics:
  - `avg_answers_per_question`, `accepted_answer_rate`  
- Additional potential features:
  - Question score, user reputation, time-to-first-answer  

It’s **production-ready** for dashboards, reports, or research studies.

---

## ⚡ Performance & Cost

- Bytes processed: **1.27 GB**  
- Execution time: ~**8 seconds**  
- Slot milliseconds: ~**581,426**  
- Optimized to **scan source data only once** for both single tags and tag pairs.
