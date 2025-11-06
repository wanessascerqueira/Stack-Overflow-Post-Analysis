# 🚀 Stack Overflow Question Quality Analysis

## 🎯 Objective
This repository contains a **SQL query and supporting resources** to analyze **qualities of Stack Overflow questions** that correlate with higher engagement, measured by **average answers per question** and **accepted answer rate**.  

The focus is on **post features beyond tags**, such as title length, score, view count, answer count, and author reputation, and on creating **actionable categories** for strategic analysis.

> **Data source:** BigQuery public Stack Overflow dataset  
> **Dashboard (bonus):** [StackOverflow Strategic Analysis](https://lookerstudio.google.com/u/0/reporting/2aa2af5f-022b-4426-84cd-76c26efb066c/page/dsYeF)  
> **Saved table (bonus):** [Google Sheet](https://docs.google.com/spreadsheets/d/1ZizpQiR505M3pvRi97VKpzPh1Mdkb9uhITVrZhYIr9w/edit?gid=1144147602#gid=1144147602)

---

## 🛠 SQL Query Logic

The query is designed to **identify question features correlated with high engagement**. The steps are:

### 1. Filter Unique Question Authors
- Only include questions with a valid `owner_user_id`.  
- Pre-aggregate distinct authors to reduce join size and improve performance.

### 2. Aggregate User Reputation
- Join question authors with `users` table to get `reputation`.  
- Bucket reputation into `<100`, `100-1000`, `>1000` for analysis.

### 3. Bucket Post Features
For clarity and visualization, several features are aggregated into buckets:

| Feature | Buckets | Purpose |
|---------|--------|---------|
| Title length | `<50`, `50-80`, `>80` | Examine the effect of concise vs. long titles on engagement |
| Score | `<0`, `0-5`, `>5` | Community voting impact |
| View count | `<100`, `100-1000`, `>1000` | Popularity effect |
| Answer count | `0`, `1`, `2+` | Engagement level at posting |
| Reputation | `<100`, `100-1000`, `>1000` | Influence of author credibility |
| Accepted answer | `true` / `false` | Whether the question has an accepted answer |

### 4. Calculate Metrics
- **Total questions** per bucket combination.  
- **Average answers per question** – using `SAFE_DIVIDE` to prevent division by zero.  
- **Accepted answer rate** – proportion of questions with an accepted answer.  

### 5. Assign Strategic Categories
Each question is labeled with a **category** to provide actionable insights:

| Category | Definition |
|----------|-----------|
| High Impact | Short title, high score, top user, multiple answers, high acceptance rate |
| Popular & Answered | Many views, multiple answers, good engagement |
| Needs Review | Multiple answers but low accepted answer rate |
| Low Engagement | Few or no answers, low average answers |
| Quality Content | Long titles and high score |
| Under the Radar | Overlooked questions with moderate acceptance rate |
| Slow Burner | Older questions that may still receive answers |
| Top User, Low Engagement | High reputation user with low engagement |
| Other | Default category for all other cases |

### 6. Query Performance Considerations
- Pre-filtering authors reduces join size.  
- Aggregation buckets reduce scanned data.  
- `SAFE_DIVIDE` prevents errors.  
- Optimized to **scan source data only once**.

---

## 🔍 Data Quality Considerations

| Aspect | Strategy |
|--------|---------|
| Missing owner_user_id | Excluded to ensure valid user joins |
| Division by zero | `SAFE_DIVIDE` used for averages and rates |
| Aggregation buckets | Reduce noise, simplify visualization |
| Validation | Cross-checked totals, averages, and acceptance rates |

---

## 📊 Dashboard (Bonus)
A **Looker Studio dashboard** was built on top of the query results for interactive exploration:

### Filters
- **Year** – explore trends over time.  
- **Category** – filter by strategic question category.

### Big Numbers / KPIs
- **Average Answers per Question**  
- **Accepted Answer Rate**  
- **Total Questions**

### Visualizations
- Total Questions by Category  
- Total Questions & Avg Answers per Year  
- Total Questions by Category & Reputation  
- Questions Distribution by Score  
- Questions Distribution by Views  
- Questions Distribution by Answer Count

> The dashboard provides a **strategic view** of question engagement and allows slicing and dicing the data by multiple dimensions.

---

## 🧱 Extendability
The query and structure support:

- Multi-year analysis (year-over-year trends).  
- Addition of new question features or alternative bucket schemes.  
- Production-ready metrics for dashboards, reports, or research.  
- Easy integration with other Stack Overflow analyses, such as tags or tag pairs.

---

## ⚡ Performance & Cost
- **Query duration:** 3 seconds  
- **Bytes processed:** 2.43 GB  
- **Bytes billed:** 2.44 GB  
- **Slot milliseconds:** 151,856  

- Optimized for BigQuery with pre-filtered question authors and aggregation buckets.  
- Bucketing reduces scanned data and improves efficiency.  
- `SAFE_DIVIDE` ensures robust execution without errors.
