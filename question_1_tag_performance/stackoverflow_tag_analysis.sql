-- ================================================================
-- Stack Overflow Tag & Tag-Combination Performance Analysis (Most Recent Year)
-- Author: Wanessa Cerqueira
-- ================================================================
-- Objective:
--   "What tags on a Stack Overflow question lead to the most answers
--    and the highest rate of approved answers for the current year?
--    What tags lead to the least? How about combinations of tags?"
--
-- Notes:
--   - Dynamically adapts to the most recent year available in the dataset.
--   - Processes the Stack Overflow dataset efficiently (≈1.27 GB total).
--   - Uses SAFE_DIVIDE for stable ratio computations.
--   - Applies thresholds (≥10 questions) for statistical reliability.
--   - Produces unified insights for both single tags and tag pairs.
-- ================================================================

-- -------------------------------
-- Step 1: Detect the most recent year available
-- -------------------------------
WITH latest_year AS (
  SELECT MAX(EXTRACT(YEAR FROM creation_date)) AS max_year
  FROM `bigquery-public-data.stackoverflow.posts_questions`
),

-- -------------------------------
-- Step 2: Retrieve question-level data for that year
-- -------------------------------
questions_current_year AS (
  SELECT
    q.id AS question_id,
    q.accepted_answer_id,
    SPLIT(LOWER(q.tags), '|') AS tag_array
  FROM `bigquery-public-data.stackoverflow.posts_questions` q
  JOIN latest_year y
    ON EXTRACT(YEAR FROM q.creation_date) = y.max_year
  WHERE q.tags IS NOT NULL
),

-- -------------------------------
-- Step 3: Aggregate total answers per question
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
-- Step 4: Combine questions, answers, and accepted-answer flags
-- -------------------------------
questions_with_answers AS (
  SELECT
    q.question_id,
    q.tag_array,
    COALESCE(a.total_answers, 0) AS total_answers,
    CASE WHEN q.accepted_answer_id IS NOT NULL THEN 1 ELSE 0 END AS has_accepted_answer
  FROM questions_current_year q
  LEFT JOIN answers_summary a
    ON q.question_id = a.question_id
),

-- -------------------------------
-- Step 5: Expand data for single-tag analysis
-- -------------------------------
questions_exploded AS (
  SELECT
    q.question_id,
    tag,
    q.total_answers,
    q.has_accepted_answer
  FROM questions_with_answers q,
  UNNEST(q.tag_array) AS tag
),

-- -------------------------------
-- Step 6: Compute single-tag metrics
-- -------------------------------
tag_metrics AS (
  SELECT
    tag AS tag_label,
    COUNT(DISTINCT question_id) AS total_questions,
    SUM(total_answers) AS total_answers,
    SUM(has_accepted_answer) AS total_accepted_questions,
    SAFE_DIVIDE(SUM(total_answers), COUNT(DISTINCT question_id)) AS avg_answers_per_question,
    SAFE_DIVIDE(SUM(has_accepted_answer), COUNT(DISTINCT question_id)) AS accepted_answer_rate
  FROM questions_exploded
  GROUP BY tag_label
  HAVING total_questions >= 10
),

-- -------------------------------
-- Step 7: Compute tag-pair (combination) metrics
-- -------------------------------
tag_pair_metrics AS (
  SELECT
    CONCAT(LEAST(t1, t2), ' | ', GREATEST(t1, t2)) AS tag_label,
    COUNT(DISTINCT q.question_id) AS total_questions,
    SUM(q.total_answers) AS total_answers,
    SUM(q.has_accepted_answer) AS total_accepted_questions,
    SAFE_DIVIDE(SUM(q.total_answers), COUNT(DISTINCT q.question_id)) AS avg_answers_per_question,
    SAFE_DIVIDE(SUM(q.has_accepted_answer), COUNT(DISTINCT q.question_id)) AS accepted_answer_rate
  FROM questions_with_answers q,
  UNNEST(q.tag_array) AS t1,
  UNNEST(q.tag_array) AS t2
  WHERE t1 < t2
  GROUP BY tag_label
  HAVING total_questions >= 10
),

-- -------------------------------
-- Step 8: Rank tags and tag-pairs by performance
-- -------------------------------
ranked_metrics AS (
  SELECT
    tag_label,
    total_questions,
    ROUND(avg_answers_per_question, 2) AS avg_answers_per_question,
    ROUND(accepted_answer_rate, 2) AS accepted_answer_rate,
    RANK() OVER (ORDER BY accepted_answer_rate DESC, avg_answers_per_question DESC) AS best_rank,
    RANK() OVER (ORDER BY accepted_answer_rate ASC, avg_answers_per_question ASC) AS worst_rank,
    'single_tag' AS ranking_scope
  FROM tag_metrics
  UNION ALL
  SELECT
    tag_label,
    total_questions,
    ROUND(avg_answers_per_question, 2),
    ROUND(accepted_answer_rate, 2),
    RANK() OVER (ORDER BY accepted_answer_rate DESC, avg_answers_per_question DESC),
    RANK() OVER (ORDER BY accepted_answer_rate ASC, avg_answers_per_question ASC),
    'tag_pair' AS ranking_scope
  FROM tag_pair_metrics
),

-- -------------------------------
-- Step 9: Select top and bottom performers per scope
-- -------------------------------
final_ranked AS (
  SELECT
    ranking_scope,
    'top' AS ranking_type,
    tag_label,
    total_questions,
    avg_answers_per_question,
    accepted_answer_rate,
    best_rank AS rank_order
  FROM ranked_metrics
  WHERE best_rank <= 10
  UNION ALL
  SELECT
    ranking_scope,
    'bottom' AS ranking_type,
    tag_label,
    total_questions,
    avg_answers_per_question,
    accepted_answer_rate,
    worst_rank AS rank_order
  FROM ranked_metrics
  WHERE worst_rank <= 10
)

-- -------------------------------
-- Step 10: Final Output
-- -------------------------------
SELECT
  ranking_scope,
  ranking_type,
  tag_label,
  total_questions,
  avg_answers_per_question,
  accepted_answer_rate,
  rank_order AS rank_position
FROM final_ranked
ORDER BY
  ranking_scope,
  CASE ranking_type WHEN 'top' THEN 1 ELSE 2 END,
  rank_order;
