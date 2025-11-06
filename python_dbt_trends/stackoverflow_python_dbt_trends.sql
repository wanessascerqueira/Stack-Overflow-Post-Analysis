-- ================================================================
-- Stack Overflow Python vs DBT Year-over-Year Analysis
-- Author: Wanessa Cerqueira
-- ================================================================
-- Objective:
--   For posts tagged only 'python' or 'dbt':
--     - Compute year-over-year change of question-to-answer ratio
--     - Compute year-over-year change of accepted answer rate
--     - Compare Python to DBT posts over the last 10 years
-- ================================================================

-- -------------------------------
-- Step 1: Filter questions by tag ('python' or 'dbt'), single-tagged, and last 10 years
-- -------------------------------
WITH filtered_questions AS (
  SELECT
    EXTRACT(YEAR FROM q.creation_date) AS year,
    LOWER(q.tags) AS tag,
    q.id AS question_id,
    CASE WHEN q.accepted_answer_id IS NOT NULL THEN 1 ELSE 0 END AS has_accepted_answer
  FROM `bigquery-public-data.stackoverflow.posts_questions` q
  WHERE ARRAY_LENGTH(SPLIT(q.tags, '|')) = 1          -- Single-tagged only
    AND LOWER(q.tags) IN ('python', 'dbt')           -- Filter for python or dbt
    AND EXTRACT(YEAR FROM q.creation_date) >= 2012   -- Last 10 years (2013-2022)
),

-- -------------------------------
-- Step 2: Aggregate total answers per question
-- -------------------------------
answers_summary AS (
  SELECT
    parent_id AS question_id,
    COUNT(*) AS total_answers
  FROM `bigquery-public-data.stackoverflow.posts_answers`
  WHERE parent_id IS NOT NULL
  GROUP BY question_id
),

-- -------------------------------
-- Step 3: Combine questions and answers
-- -------------------------------
questions_with_answers AS (
  SELECT
    f.year,
    f.tag,
    COUNT(DISTINCT f.question_id) AS total_questions,
    -- Average answers per question, rounded to 2 decimals
    ROUND(SAFE_DIVIDE(SUM(a.total_answers), COUNT(DISTINCT f.question_id)), 2) AS avg_answers_per_question,
    -- Accepted answer rate, rounded to 2 decimals
    ROUND(SAFE_DIVIDE(SUM(f.has_accepted_answer), COUNT(DISTINCT f.question_id)), 2) AS accepted_answer_rate
  FROM filtered_questions f
  LEFT JOIN answers_summary a
    ON f.question_id = a.question_id
  GROUP BY year, tag
  HAVING total_questions > 0  -- Exclude years with zero questions
),

-- -------------------------------
-- Step 4: Calculate year-over-year change using LAG
-- -------------------------------
ranked_questions AS (
  SELECT
    *,
    LAG(avg_answers_per_question) OVER (PARTITION BY tag ORDER BY year) AS prev_avg_answers,
    LAG(accepted_answer_rate) OVER (PARTITION BY tag ORDER BY year) AS prev_accepted_rate
  FROM questions_with_answers
)

-- -------------------------------
-- Step 5: Compute YoY percentage changes
-- -------------------------------
SELECT
  year,
  tag,
  total_questions,
  avg_answers_per_question,
  accepted_answer_rate,
  -- YoY change in average answers (%)
  ROUND(SAFE_DIVIDE(avg_answers_per_question - prev_avg_answers, prev_avg_answers) * 100, 2) AS yoy_change_avg_answers_pct,
  -- YoY change in accepted answer rate (%)
  ROUND(SAFE_DIVIDE(accepted_answer_rate - prev_accepted_rate, prev_accepted_rate) * 100, 2) AS yoy_change_accepted_rate_pct
FROM ranked_questions
ORDER BY tag, year;
