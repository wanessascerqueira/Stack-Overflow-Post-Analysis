# 📊 Stack Overflow Tag Analysis — 2025 Data Exploration

**Author:** Wanessa Cerqueira  
**Date:** November 2025  
**Tools:** Google BigQuery (public Stack Overflow dataset), Standard SQL  

---

## 🎯 Objective

The goal of this analysis is to identify:

1. **Which tags** on Stack Overflow questions lead to the **most answers** and **highest rate of accepted answers** (i.e., highest community engagement and resolution).  
2. Which tags lead to the **least answers** or **lowest acceptance rates**.  
3. **Which tag pairs (combinations)** perform best and worst.

The focus is on the **current year available** in the dataset, ensuring relevance and fair comparison.

---

## 🧠 Technical Approach

This solution follows an intentional, modular structure designed to balance:

- **Performance** (reduced data scanning and optimized joins)  
- **Clarity and readability**  
- **Scalability** (ready to be integrated into dashboards or pipelines)  
- **Data quality** validation at each step  

---

### 🧩 Step-by-step Design

1. **Identify the temporal boundary**  
   - Determine the latest year available in the dataset.  
   - Ensures the query dynamically adjusts if new data is added.

2. **Filter to the most recent year**  
   - Restrict analysis to the maximum year for consistent comparison.

3. **Expand tags into rows**  
   - Normalize tags (originally XML-like strings) into separate rows for aggregation.

4. **Join with answers**  
   - Compute number of answers per question and accepted answer flag.

5. **Aggregate by tag**  
   - Compute per-tag metrics:
     - `total_questions`  
     - `avg_answers_per_question`  
     - `accepted_answer_rate`

6. **Compute tag pairs**  
   - Generate co-occurring tag combinations to identify synergistic topics.  
   - Lexicographically order tags to avoid duplicate pairs.

7. **Rank performance**  
   - Use `ROW_NUMBER()` or `RANK()` to extract:
     - Top-performing tags and tag pairs  
     - Bottom-performing tags and tag pairs

8. **Combine all results**  
   - Unified output for **single tags** and **tag pairs**, with consistent column names for dashboarding or downstream use.

9. **Optimize performance**  
   - Modular CTEs and late aggregations reduce scanned data.  
   - Total scan: ≈1.27 GB for full query execution (~8s runtime).

10. **Document and validate**  
    - Meaningful column names, comments, and consistent ranking logic ensure reproducibility and data quality.

---

## 📈 Results Summary

### 🏆 Top Performing Tags

| Rank | Tag | Avg Answers | Accepted Rate |
|------|-----|-------------|---------------|
| 1    | `conditional-aggregation` | 1.39 | 0.96 |
| 2    | `sql-in`                  | 1.27 | 0.91 |
| 3    | `select-object`           | 1.18 | 0.91 |
| 10   | `google-query-language`   | 1.22 | 0.90 |

**Interpretation:**  
High-performing tags generally represent **core data, aggregation, and query concepts**. These topics are common and widely understood.

---

### ⚠️ Lowest Performing Tags

| Rank | Tag | Avg Answers | Accepted Rate |
|------|-----|-------------|---------------|
| 1    | `kombu`                  | 0.0 | 0.0 |
| 1    | `vagrant-windows`        | 0.0 | 0.0 |
| 1    | `safari-web-inspector`   | 0.0 | 0.0 |

**Interpretation:**  
Low engagement indicates **niche or outdated technologies** with fewer expert contributors.

---

### 🏆 Top Performing Tag Pairs

| Rank | Tag Pair | Avg Answers | Accepted Rate |
|------|----------|-------------|---------------|
| 1    | `common-table-expression | sql-update` | 1.55 | 1.0 |
| 2    | `sorting | vlookup`                   | 1.42 | 1.0 |
| 3    | `conditional-aggregation | group-by` | 1.38 | 1.0 |

**Interpretation:**  
Synergistic tag combinations reflect **specific, high-value topics** that attract quick and accurate answers.

---

### ⚠️ Lowest Performing Tag Pairs

| Rank | Tag Pair | Avg Answers | Accepted Rate |
|------|----------|-------------|---------------|
| 1    | `flutter | object-detection`              | 0.0 | 0.0 |
| 1    | `amazon-kinesis | apache-spark`          | 0.0 | 0.0 |

**Interpretation:**  
These pairs mix **distant domains** where community expertise is sparse.

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
