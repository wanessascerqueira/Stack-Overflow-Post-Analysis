-- ============================================================================
-- StackOverflow Questions Strategic Metrics
-- Author: Wanessa Cerqueira
-- Objective:
--   Identify post qualities that correlate with higher answer and accepted answer rates
-- Author: Wanessa Cerqueira
-- Notes: 
--   - Optimized for performance: only joining users who authored questions.
--   - Uses SAFE_DIVIDE to prevent division by zero errors.
--   - Aggregates metrics into buckets for clarity and visualization.
--   - Adds strategic labels (category) for actionable insights.
-- ============================================================================

WITH

-- ----------------------------------------------------------------------------
-- Step 1: Identify unique question authors to reduce join size
-- ----------------------------------------------------------------------------
unique_question_users AS (
  SELECT DISTINCT owner_user_id
  FROM `bigquery-public-data.stackoverflow.posts_questions`
  WHERE owner_user_id IS NOT NULL
),

-- ----------------------------------------------------------------------------
-- Step 2: Get reputation only for relevant users
-- ----------------------------------------------------------------------------
user_reputation AS (
  SELECT
    u.id AS user_id,
    u.reputation
  FROM `bigquery-public-data.stackoverflow.users` u
  INNER JOIN unique_question_users uq
    ON u.id = uq.owner_user_id
),

-- ----------------------------------------------------------------------------
-- Step 3: Aggregate question features into buckets
-- ----------------------------------------------------------------------------
post_questions AS (
  SELECT
    EXTRACT(YEAR FROM pq.creation_date) AS year,

    -- Title length bucket
    CASE 
      WHEN LENGTH(pq.title) < 50 THEN '<50'
      WHEN LENGTH(pq.title) BETWEEN 50 AND 80 THEN '50-80'
      ELSE '>80'
    END AS title_length_bucket,

    -- Score bucket
    CASE 
      WHEN pq.score < 0 THEN '<0'
      WHEN pq.score BETWEEN 0 AND 5 THEN '0-5'
      ELSE '>5'
    END AS score_bucket,

    -- View count bucket
    CASE 
      WHEN pq.view_count < 100 THEN '<100'
      WHEN pq.view_count BETWEEN 100 AND 1000 THEN '100-1000'
      ELSE '>1000'
    END AS view_count_bucket,

    -- Answer count bucket
    CASE 
      WHEN pq.answer_count = 0 THEN '0'
      WHEN pq.answer_count = 1 THEN '1'
      ELSE '2+'
    END AS answer_count_bucket,

    -- User reputation bucket
    CASE 
      WHEN ur.reputation < 100 THEN '<100'
      WHEN ur.reputation BETWEEN 100 AND 1000 THEN '100-1000'
      ELSE '>1000'
    END AS reputation_bucket,

    -- Accepted answer flag
    pq.accepted_answer_id IS NOT NULL AS has_accepted_answer

  FROM `bigquery-public-data.stackoverflow.posts_questions` pq
  LEFT JOIN user_reputation ur
    ON pq.owner_user_id = ur.user_id
),

-- ----------------------------------------------------------------------------
-- Step 4: Aggregate metrics by all buckets
-- ----------------------------------------------------------------------------
question_agg AS (
  SELECT
    year,
    title_length_bucket,
    score_bucket,
    view_count_bucket,
    answer_count_bucket,
    reputation_bucket,
    COUNT(*) AS total_questions,
    
    -- Avg answers per question (0 if no answers)
    ROUND(SAFE_DIVIDE(SUM(CAST(answer_count_bucket != '0' AS INT64)), COUNT(*)),2) AS avg_answers_per_question,

    -- Accepted answer rate (0 if no accepted answers)
    ROUND(SAFE_DIVIDE(SUM(CAST(has_accepted_answer AS INT64)), COUNT(*)),2) AS accepted_answer_rate

  FROM post_questions
  GROUP BY
    year, title_length_bucket, score_bucket, view_count_bucket, answer_count_bucket, reputation_bucket
)

-- ----------------------------------------------------------------------------
-- Step 5: Add strategic labels (category) for dashboard visualization
-- ----------------------------------------------------------------------------
SELECT
  *,
  CASE
    -- High Impact: Short title, high score, top user, multiple answers, high acceptance rate
    WHEN title_length_bucket = '<50' 
         AND score_bucket = '>5' 
         AND reputation_bucket = '>1000' 
         AND avg_answers_per_question >= 1 
         AND accepted_answer_rate >= 0.9
      THEN 'High Impact'

    -- Popular & Answered: Many views, multiple answers, good engagement
    WHEN view_count_bucket = '>1000'
         AND answer_count_bucket = '2+' 
         AND avg_answers_per_question >= 1
      THEN 'Popular & Answered'

    -- Needs Review: Multiple answers but low acceptance rate
    WHEN answer_count_bucket = '2+' 
         AND accepted_answer_rate < 0.5
      THEN 'Needs Review'

    -- Low Engagement: Few or no answers, low average answers
    WHEN answer_count_bucket = '0' 
         OR avg_answers_per_question < 1
      THEN 'Low Engagement'

    -- Quality Content: Long titles and high score
    WHEN title_length_bucket = '>80'
         AND score_bucket = '>5'
      THEN 'Quality Content'

    -- Under the Radar: Overlooked questions, few views/answers, medium acceptance rate
    WHEN title_length_bucket IN ('<50', '50-80')
         AND score_bucket IN ('0-5', '>5')
         AND view_count_bucket IN ('<100', '100-1000')
         AND answer_count_bucket IN ('1', '2+')
         AND accepted_answer_rate BETWEEN 0.4 AND 0.6
      THEN 'Under the Radar'

    -- Slow Burner: Older questions that may still receive answers
    WHEN year < 2015
         AND answer_count_bucket IN ('1', '2+')
         AND accepted_answer_rate < 0.6
      THEN 'Slow Burner'

    -- High Reputation, Low Engagement: High reputation user but low engagement
    WHEN reputation_bucket = '>1000'
         AND answer_count_bucket IN ('0','1')
         AND accepted_answer_rate < 0.6
      THEN 'Top User, Low Engagement'

    -- Default category for all other cases
    ELSE 'Other'
  END AS category

FROM question_agg
ORDER BY total_questions DESC;
