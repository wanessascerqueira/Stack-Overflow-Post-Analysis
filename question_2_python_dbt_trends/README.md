# 🚀 Stack Overflow Year-over-Year Analysis: Python vs DBT

## 🎯 Objective

For posts tagged **only** with `python` or `dbt`, this analysis:

- Computes year-over-year (YoY) change of **question-to-answer ratio**.  
- Computes year-over-year change of **accepted answer rate**.  
- Compares Python to DBT posts over the last decade (2012–2022).

---

## 🛠 SQL Technical Approach

1. **Filter single-tagged questions**  
   Only posts with one tag (`python` or `dbt`) are considered to avoid mixing topics.  

2. **Aggregate answers**  
   Count total answers per question using the `posts_answers` table.  

3. **Combine and compute metrics**  
   - `avg_answers_per_question`: Average number of answers per question (rounded to 2 decimals)  
   - `accepted_answer_rate`: Proportion of questions with an accepted answer  

4. **Calculate year-over-year (YoY) changes**  
   Using the `LAG()` window function partitioned by tag to compute percentage change from the previous year.  

5. **Rounding and safety**  
   All calculations use `SAFE_DIVIDE()` to prevent division errors and are rounded to 2 decimals.  

---

## 📊 Analysis Results

| Year | Tag   | Total Questions | Avg Answers per Question | Accepted Answer Rate | YoY Δ Avg Answers (%) | YoY Δ Accepted Rate (%) |
|------|-------|-----------------|--------------------------|----------------------|-----------------------|--------------------------|
| 2012 | python | 5,749 | 2.63 | 0.72 | null | null |
| 2013 | python | 7,819 | 2.31 | 0.65 | -12.17 | -9.72 |
| 2014 | python | 8,537 | 1.97 | 0.61 | -14.72 | -6.15 |
| 2015 | python | 9,781 | 1.90 | 0.57 | -3.55 | -6.56 |
| 2016 | python | 10,344 | 1.83 | 0.53 | -3.68 | -7.02 |
| 2017 | python | 11,683 | 1.70 | 0.49 | -7.10 | -7.55 |
| 2018 | python | 11,614 | 1.69 | 0.49 | -0.59 | 0.00 |
| 2019 | python | 14,503 | 1.70 | 0.49 | 0.59 | 0.00 |
| 2020 | python | 16,256 | 1.65 | 0.45 | -2.94 | -8.16 |
| 2021 | python | 15,811 | 1.52 | 0.43 | -7.88 | -4.44 |
| 2022 | python | 12,809 | 1.26 | 0.35 | -17.11 | -18.60 |
| 2020 | dbt    | 31    | 1.39 | 0.42 | null | null |
| 2021 | dbt    | 58    | 1.14 | 0.26 | -17.99 | -38.10 |
| 2022 | dbt    | 79    | 1.06 | 0.28 | -7.02 | 7.69 |

**Notes:**  
- `YoY Δ` = Year-over-year percentage change from the previous year.  
- `null` = No previous year to compare.  
- Values are rounded to 2 decimals.

---

## 🔍 Interpretation & Strategic Insights

1. **Python vs DBT Volume**  
   - Python has **substantially higher volume** of questions each year, reflecting a mature and active community.  
   - DBT, being a more recent technology, shows smaller counts (tens of questions per year), leading to higher volatility in metrics.

2. **Question-to-Answer Ratio Trends**  
   - Python’s **average answers per question** steadily declined from **2.63 (2012)** → **1.26 (2022)**, suggesting that the community’s growth in question volume outpaced the growth in active answerers.  
   - DBT shows fluctuations, but averages remain close to **1 answer per question**, which is reasonable for a smaller tag ecosystem.

3. **Accepted Answer Rate**  
   - Python’s accepted answer rate dropped from **0.72 → 0.35**, a gradual decline that may reflect shifts toward discussion-style questions or alternative learning sources (e.g., GitHub, Discord, Reddit).  
   - DBT’s acceptance rate fell sharply from **0.42 → 0.26 (2021)**, then rebounded slightly in 2022 (**+7.7% YoY**), consistent with a young but stabilizing community.

4. **Year-over-Year Changes**  
   - Python’s YoY deltas are consistently negative — expected for large ecosystems where growth in questions exceeds answer supply.  
   - DBT’s YoY deltas show large swings due to small sample sizes (few dozen questions per year), which amplifies percentage volatility.

---

## 📈 Data Quality & Methodology Notes

| Aspect | Strategy |
|--------|----------|
| **Single-tag filtering** | Ensures results reflect questions explicitly about one technology. |
| **Questions without answers** | Included via `LEFT JOIN` to preserve completeness. |
| **Division safety** | All divisions use `SAFE_DIVIDE()` to avoid null errors. |
| **Temporal coverage** | Last 10 years (2012–2022). |
| **Validation** | Results cross-checked for consistency across both datasets. |

---

## 🧱 Extendability

This SQL structure can easily be extended for:

- Additional tags (e.g., `r`, `pandas`, `sql`).  
- Multi-metric dashboards (e.g., user reputation, time-to-first-answer).  
- Visual analyses of **YoY trends** and **community maturity** using tools like Looker Studio or Power BI.

---

## ⚡ Performance & Cost

- **Bytes processed:** ~1.3 GB  
- **Execution time:** ~3 seconds  
- **Slot milliseconds:** ~93,000  
- Optimized to **scan source tables only once**, leveraging pre-aggregations and window functions efficiently.

---

## 🧩 Example Dashboard Ideas

- **Trend Line:** Average Answers per Question (YoY)  
- **Bar Chart:** Accepted Answer Rate by Tag and Year  
- **Table Comparison:** YoY % Change for Both Metrics  
- **Context Panel:** Number of Questions per Year (Community Growth Indicator)
