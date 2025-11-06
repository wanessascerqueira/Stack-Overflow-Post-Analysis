{\rtf1\ansi\ansicpg1252\cocoartf2636
\cocoatextscaling0\cocoaplatform0{\fonttbl\f0\fnil\fcharset0 Menlo-Regular;}
{\colortbl;\red255\green255\blue255;\red167\green0\blue95;\red255\green255\blue255;\red24\green25\blue27;
\red22\green79\blue199;\red0\green0\blue0;\red46\green49\blue51;\red24\green112\blue43;\red159\green77\blue4;
}
{\*\expandedcolortbl;;\cssrgb\c72157\c2353\c44706;\cssrgb\c100000\c100000\c100000;\cssrgb\c12549\c12941\c14118;
\cssrgb\c9804\c40392\c82353;\cssrgb\c0\c0\c0;\cssrgb\c23529\c25098\c26275;\cssrgb\c9412\c50196\c21961;\cssrgb\c69020\c37647\c0;
}
\paperw11900\paperh16840\margl1440\margr1440\vieww11520\viewh8400\viewkind0
\deftab720
\pard\pardeftab720\partightenfactor0

\f0\fs24 \cf2 \cb3 \expnd0\expndtw0\kerning0
\outl0\strokewidth0 \strokec2 -- ================================================================\cf4 \cb1 \strokec4 \
\cf2 \cb3 \strokec2 -- Stack Overflow Tag & Tag-Combination Performance Analysis (Most Recent Year)\cf4 \cb1 \strokec4 \
\cf2 \cb3 \strokec2 -- Author: Wanessa Cerqueira\cf4 \cb1 \strokec4 \
\cf2 \cb3 \strokec2 -- ================================================================\cf4 \cb1 \strokec4 \
\cf2 \cb3 \strokec2 -- Objective:\cf4 \cb1 \strokec4 \
\cf2 \cb3 \strokec2 --   "What tags on a Stack Overflow question lead to the most answers\cf4 \cb1 \strokec4 \
\cf2 \cb3 \strokec2 --    and the highest rate of approved answers for the current year?\cf4 \cb1 \strokec4 \
\cf2 \cb3 \strokec2 --    What tags lead to the least? How about combinations of tags?"\cf4 \cb1 \strokec4 \
\cf2 \cb3 \strokec2 --\cf4 \cb1 \strokec4 \
\cf2 \cb3 \strokec2 -- Notes:\cf4 \cb1 \strokec4 \
\cf2 \cb3 \strokec2 --   - Dynamically adapts to the most recent year available in the dataset.\cf4 \cb1 \strokec4 \
\cf2 \cb3 \strokec2 --   - Processes the Stack Overflow dataset efficiently (\uc0\u8776 1.27 GB total).\cf4 \cb1 \strokec4 \
\cf2 \cb3 \strokec2 --   - Uses SAFE_DIVIDE for stable ratio computations.\cf4 \cb1 \strokec4 \
\cf2 \cb3 \strokec2 --   - Applies thresholds (\uc0\u8805 10 questions) for statistical reliability.\cf4 \cb1 \strokec4 \
\cf2 \cb3 \strokec2 --   - Produces unified insights for both single tags and tag pairs.\cf4 \cb1 \strokec4 \
\cf2 \cb3 \strokec2 -- ================================================================\cf4 \cb1 \strokec4 \
\
\cf2 \cb3 \strokec2 -- -------------------------------\cf4 \cb1 \strokec4 \
\cf2 \cb3 \strokec2 -- Step 1: Detect the most recent year available\cf4 \cb1 \strokec4 \
\cf2 \cb3 \strokec2 -- -------------------------------\cf4 \cb1 \strokec4 \
\pard\pardeftab720\partightenfactor0
\cf5 \cb3 \strokec5 WITH\cf4 \strokec4  \strokec6 latest_year\strokec4  \cf5 \strokec5 AS\cf4 \strokec4  \cf7 \strokec7 (\cf4 \cb1 \strokec4 \
\pard\pardeftab720\partightenfactor0
\cf4 \cb3   \cf5 \strokec5 SELECT\cf4 \strokec4  \cf5 \strokec5 MAX\cf7 \strokec7 (\cf5 \strokec5 EXTRACT\cf7 \strokec7 (\cf4 \strokec6 YEAR\strokec4  \cf5 \strokec5 FROM\cf4 \strokec4  \strokec6 creation_date\cf7 \strokec7 ))\cf4 \strokec4  \cf5 \strokec5 AS\cf4 \strokec4  \strokec6 max_year\cb1 \strokec4 \
\cb3   \cf5 \strokec5 FROM\cf4 \strokec4  \strokec6 `bigquery-public-data.stackoverflow.posts_questions`\cb1 \strokec4 \
\pard\pardeftab720\partightenfactor0
\cf7 \cb3 \strokec7 )\cf4 \strokec4 ,\cb1 \
\
\pard\pardeftab720\partightenfactor0
\cf2 \cb3 \strokec2 -- -------------------------------\cf4 \cb1 \strokec4 \
\cf2 \cb3 \strokec2 -- Step 2: Retrieve question-level data for that year\cf4 \cb1 \strokec4 \
\cf2 \cb3 \strokec2 -- -------------------------------\cf4 \cb1 \strokec4 \
\pard\pardeftab720\partightenfactor0
\cf4 \cb3 \strokec6 questions_current_year\strokec4  \cf5 \strokec5 AS\cf4 \strokec4  \cf7 \strokec7 (\cf4 \cb1 \strokec4 \
\pard\pardeftab720\partightenfactor0
\cf4 \cb3   \cf5 \strokec5 SELECT\cf4 \cb1 \strokec4 \
\cb3     \strokec6 q.id\strokec4  \cf5 \strokec5 AS\cf4 \strokec4  \strokec6 question_id\strokec4 ,\cb1 \
\cb3     \strokec6 q.accepted_answer_id\strokec4 ,\cb1 \
\cb3     \cf5 \strokec5 SPLIT\cf7 \strokec7 (\cf5 \strokec5 LOWER\cf7 \strokec7 (\cf4 \strokec6 q.tags\cf7 \strokec7 )\cf4 \strokec4 , \cf8 \strokec8 '|'\cf7 \strokec7 )\cf4 \strokec4  \cf5 \strokec5 AS\cf4 \strokec4  \strokec6 tag_array\cb1 \strokec4 \
\cb3   \cf5 \strokec5 FROM\cf4 \strokec4  \strokec6 `bigquery-public-data.stackoverflow.posts_questions`\strokec4  \strokec6 q\cb1 \strokec4 \
\cb3   \cf5 \strokec5 JOIN\cf4 \strokec4  \strokec6 latest_year\strokec4  \strokec6 y\cb1 \strokec4 \
\cb3     \cf5 \strokec5 ON\cf4 \strokec4  \cf5 \strokec5 EXTRACT\cf7 \strokec7 (\cf4 \strokec6 YEAR\strokec4  \cf5 \strokec5 FROM\cf4 \strokec4  \strokec6 q.creation_date\cf7 \strokec7 )\cf4 \strokec4  = \strokec6 y.max_year\cb1 \strokec4 \
\cb3   \cf5 \strokec5 WHERE\cf4 \strokec4  \strokec6 q.tags\strokec4  \cf5 \strokec5 IS\cf4 \strokec4  \cf5 \strokec5 NOT\cf4 \strokec4  \cf5 \strokec5 NULL\cf4 \cb1 \strokec4 \
\pard\pardeftab720\partightenfactor0
\cf7 \cb3 \strokec7 )\cf4 \strokec4 ,\cb1 \
\
\pard\pardeftab720\partightenfactor0
\cf2 \cb3 \strokec2 -- -------------------------------\cf4 \cb1 \strokec4 \
\cf2 \cb3 \strokec2 -- Step 3: Aggregate total answers per question\cf4 \cb1 \strokec4 \
\cf2 \cb3 \strokec2 -- -------------------------------\cf4 \cb1 \strokec4 \
\pard\pardeftab720\partightenfactor0
\cf4 \cb3 \strokec6 answers_summary\strokec4  \cf5 \strokec5 AS\cf4 \strokec4  \cf7 \strokec7 (\cf4 \cb1 \strokec4 \
\pard\pardeftab720\partightenfactor0
\cf4 \cb3   \cf5 \strokec5 SELECT\cf4 \cb1 \strokec4 \
\cb3     \strokec6 parent_id\strokec4  \cf5 \strokec5 AS\cf4 \strokec4  \strokec6 question_id\strokec4 ,\cb1 \
\cb3     \cf5 \strokec5 COUNT\cf7 \strokec7 (*)\cf4 \strokec4  \cf5 \strokec5 AS\cf4 \strokec4  \strokec6 total_answers\cb1 \strokec4 \
\cb3   \cf5 \strokec5 FROM\cf4 \strokec4  \strokec6 `bigquery-public-data.stackoverflow.posts_answers`\cb1 \strokec4 \
\cb3   \cf5 \strokec5 WHERE\cf4 \strokec4  \strokec6 parent_id\strokec4  \cf5 \strokec5 IS\cf4 \strokec4  \cf5 \strokec5 NOT\cf4 \strokec4  \cf5 \strokec5 NULL\cf4 \cb1 \strokec4 \
\cb3   \cf5 \strokec5 GROUP\cf4 \strokec4  \cf5 \strokec5 BY\cf4 \strokec4  \strokec6 question_id\cb1 \strokec4 \
\pard\pardeftab720\partightenfactor0
\cf7 \cb3 \strokec7 )\cf4 \strokec4 ,\cb1 \
\
\pard\pardeftab720\partightenfactor0
\cf2 \cb3 \strokec2 -- -------------------------------\cf4 \cb1 \strokec4 \
\cf2 \cb3 \strokec2 -- Step 4: Combine questions, answers, and accepted-answer flags\cf4 \cb1 \strokec4 \
\cf2 \cb3 \strokec2 -- -------------------------------\cf4 \cb1 \strokec4 \
\pard\pardeftab720\partightenfactor0
\cf4 \cb3 \strokec6 questions_with_answers\strokec4  \cf5 \strokec5 AS\cf4 \strokec4  \cf7 \strokec7 (\cf4 \cb1 \strokec4 \
\pard\pardeftab720\partightenfactor0
\cf4 \cb3   \cf5 \strokec5 SELECT\cf4 \cb1 \strokec4 \
\cb3     \strokec6 q.question_id\strokec4 ,\cb1 \
\cb3     \strokec6 q.tag_array\strokec4 ,\cb1 \
\cb3     \cf5 \strokec5 COALESCE\cf7 \strokec7 (\cf4 \strokec6 a.total_answers\strokec4 , \cf9 \strokec9 0\cf7 \strokec7 )\cf4 \strokec4  \cf5 \strokec5 AS\cf4 \strokec4  \strokec6 total_answers\strokec4 ,\cb1 \
\cb3     \cf5 \strokec5 CASE\cf4 \strokec4  \cf5 \strokec5 WHEN\cf4 \strokec4  \strokec6 q.accepted_answer_id\strokec4  \cf5 \strokec5 IS\cf4 \strokec4  \cf5 \strokec5 NOT\cf4 \strokec4  \cf5 \strokec5 NULL\cf4 \strokec4  \cf5 \strokec5 THEN\cf4 \strokec4  \cf9 \strokec9 1\cf4 \strokec4  \cf5 \strokec5 ELSE\cf4 \strokec4  \cf9 \strokec9 0\cf4 \strokec4  \cf5 \strokec5 END\cf4 \strokec4  \cf5 \strokec5 AS\cf4 \strokec4  \strokec6 has_accepted_answer\cb1 \strokec4 \
\cb3   \cf5 \strokec5 FROM\cf4 \strokec4  \strokec6 questions_current_year\strokec4  \strokec6 q\cb1 \strokec4 \
\cb3   \cf5 \strokec5 LEFT\cf4 \strokec4  \cf5 \strokec5 JOIN\cf4 \strokec4  \strokec6 answers_summary\strokec4  \strokec6 a\cb1 \strokec4 \
\cb3     \cf5 \strokec5 ON\cf4 \strokec4  \strokec6 q.question_id\strokec4  = \strokec6 a.question_id\cb1 \strokec4 \
\pard\pardeftab720\partightenfactor0
\cf7 \cb3 \strokec7 )\cf4 \strokec4 ,\cb1 \
\
\pard\pardeftab720\partightenfactor0
\cf2 \cb3 \strokec2 -- -------------------------------\cf4 \cb1 \strokec4 \
\cf2 \cb3 \strokec2 -- Step 5: Expand data for single-tag analysis\cf4 \cb1 \strokec4 \
\cf2 \cb3 \strokec2 -- -------------------------------\cf4 \cb1 \strokec4 \
\pard\pardeftab720\partightenfactor0
\cf4 \cb3 \strokec6 questions_exploded\strokec4  \cf5 \strokec5 AS\cf4 \strokec4  \cf7 \strokec7 (\cf4 \cb1 \strokec4 \
\pard\pardeftab720\partightenfactor0
\cf4 \cb3   \cf5 \strokec5 SELECT\cf4 \cb1 \strokec4 \
\cb3     \strokec6 q.question_id\strokec4 ,\cb1 \
\cb3     \strokec6 tag\strokec4 ,\cb1 \
\cb3     \strokec6 q.total_answers\strokec4 ,\cb1 \
\cb3     \strokec6 q.has_accepted_answer\cb1 \strokec4 \
\cb3   \cf5 \strokec5 FROM\cf4 \strokec4  \strokec6 questions_with_answers\strokec4  \strokec6 q\strokec4 ,\cb1 \
\cb3   \cf5 \strokec5 UNNEST\cf7 \strokec7 (\cf4 \strokec6 q.tag_array\cf7 \strokec7 )\cf4 \strokec4  \cf5 \strokec5 AS\cf4 \strokec4  \strokec6 tag\cb1 \strokec4 \
\pard\pardeftab720\partightenfactor0
\cf7 \cb3 \strokec7 )\cf4 \strokec4 ,\cb1 \
\
\pard\pardeftab720\partightenfactor0
\cf2 \cb3 \strokec2 -- -------------------------------\cf4 \cb1 \strokec4 \
\cf2 \cb3 \strokec2 -- Step 6: Compute single-tag metrics\cf4 \cb1 \strokec4 \
\cf2 \cb3 \strokec2 -- -------------------------------\cf4 \cb1 \strokec4 \
\pard\pardeftab720\partightenfactor0
\cf4 \cb3 \strokec6 tag_metrics\strokec4  \cf5 \strokec5 AS\cf4 \strokec4  \cf7 \strokec7 (\cf4 \cb1 \strokec4 \
\pard\pardeftab720\partightenfactor0
\cf4 \cb3   \cf5 \strokec5 SELECT\cf4 \cb1 \strokec4 \
\cb3     \strokec6 tag\strokec4  \cf5 \strokec5 AS\cf4 \strokec4  \strokec6 tag_label\strokec4 ,\cb1 \
\cb3     \cf5 \strokec5 COUNT\cf7 \strokec7 (\cf5 \strokec5 DISTINCT\cf4 \strokec4  \strokec6 question_id\cf7 \strokec7 )\cf4 \strokec4  \cf5 \strokec5 AS\cf4 \strokec4  \strokec6 total_questions\strokec4 ,\cb1 \
\cb3     \cf5 \strokec5 SUM\cf7 \strokec7 (\cf4 \strokec6 total_answers\cf7 \strokec7 )\cf4 \strokec4  \cf5 \strokec5 AS\cf4 \strokec4  \strokec6 total_answers\strokec4 ,\cb1 \
\cb3     \cf5 \strokec5 SUM\cf7 \strokec7 (\cf4 \strokec6 has_accepted_answer\cf7 \strokec7 )\cf4 \strokec4  \cf5 \strokec5 AS\cf4 \strokec4  \strokec6 total_accepted_questions\strokec4 ,\cb1 \
\cb3     \cf5 \strokec5 SAFE_DIVIDE\cf7 \strokec7 (\cf5 \strokec5 SUM\cf7 \strokec7 (\cf4 \strokec6 total_answers\cf7 \strokec7 )\cf4 \strokec4 , \cf5 \strokec5 COUNT\cf7 \strokec7 (\cf5 \strokec5 DISTINCT\cf4 \strokec4  \strokec6 question_id\cf7 \strokec7 ))\cf4 \strokec4  \cf5 \strokec5 AS\cf4 \strokec4  \strokec6 avg_answers_per_question\strokec4 ,\cb1 \
\cb3     \cf5 \strokec5 SAFE_DIVIDE\cf7 \strokec7 (\cf5 \strokec5 SUM\cf7 \strokec7 (\cf4 \strokec6 has_accepted_answer\cf7 \strokec7 )\cf4 \strokec4 , \cf5 \strokec5 COUNT\cf7 \strokec7 (\cf5 \strokec5 DISTINCT\cf4 \strokec4  \strokec6 question_id\cf7 \strokec7 ))\cf4 \strokec4  \cf5 \strokec5 AS\cf4 \strokec4  \strokec6 accepted_answer_rate\cb1 \strokec4 \
\cb3   \cf5 \strokec5 FROM\cf4 \strokec4  \strokec6 questions_exploded\cb1 \strokec4 \
\cb3   \cf5 \strokec5 GROUP\cf4 \strokec4  \cf5 \strokec5 BY\cf4 \strokec4  \strokec6 tag_label\cb1 \strokec4 \
\cb3   \cf5 \strokec5 HAVING\cf4 \strokec4  \strokec6 total_questions\strokec4  \cf7 \strokec7 >=\cf4 \strokec4  \cf9 \strokec9 10\cf4 \cb1 \strokec4 \
\pard\pardeftab720\partightenfactor0
\cf7 \cb3 \strokec7 )\cf4 \strokec4 ,\cb1 \
\
\pard\pardeftab720\partightenfactor0
\cf2 \cb3 \strokec2 -- -------------------------------\cf4 \cb1 \strokec4 \
\cf2 \cb3 \strokec2 -- Step 7: Compute tag-pair (combination) metrics\cf4 \cb1 \strokec4 \
\cf2 \cb3 \strokec2 -- -------------------------------\cf4 \cb1 \strokec4 \
\pard\pardeftab720\partightenfactor0
\cf4 \cb3 \strokec6 tag_pair_metrics\strokec4  \cf5 \strokec5 AS\cf4 \strokec4  \cf7 \strokec7 (\cf4 \cb1 \strokec4 \
\pard\pardeftab720\partightenfactor0
\cf4 \cb3   \cf5 \strokec5 SELECT\cf4 \cb1 \strokec4 \
\cb3     \cf5 \strokec5 CONCAT\cf7 \strokec7 (\cf5 \strokec5 LEAST\cf7 \strokec7 (\cf4 \strokec6 t1\strokec4 , \strokec6 t2\cf7 \strokec7 )\cf4 \strokec4 , \cf8 \strokec8 ' | '\cf4 \strokec4 , \cf5 \strokec5 GREATEST\cf7 \strokec7 (\cf4 \strokec6 t1\strokec4 , \strokec6 t2\cf7 \strokec7 ))\cf4 \strokec4  \cf5 \strokec5 AS\cf4 \strokec4  \strokec6 tag_label\strokec4 ,\cb1 \
\cb3     \cf5 \strokec5 COUNT\cf7 \strokec7 (\cf5 \strokec5 DISTINCT\cf4 \strokec4  \strokec6 q.question_id\cf7 \strokec7 )\cf4 \strokec4  \cf5 \strokec5 AS\cf4 \strokec4  \strokec6 total_questions\strokec4 ,\cb1 \
\cb3     \cf5 \strokec5 SUM\cf7 \strokec7 (\cf4 \strokec6 q.total_answers\cf7 \strokec7 )\cf4 \strokec4  \cf5 \strokec5 AS\cf4 \strokec4  \strokec6 total_answers\strokec4 ,\cb1 \
\cb3     \cf5 \strokec5 SUM\cf7 \strokec7 (\cf4 \strokec6 q.has_accepted_answer\cf7 \strokec7 )\cf4 \strokec4  \cf5 \strokec5 AS\cf4 \strokec4  \strokec6 total_accepted_questions\strokec4 ,\cb1 \
\cb3     \cf5 \strokec5 SAFE_DIVIDE\cf7 \strokec7 (\cf5 \strokec5 SUM\cf7 \strokec7 (\cf4 \strokec6 q.total_answers\cf7 \strokec7 )\cf4 \strokec4 , \cf5 \strokec5 COUNT\cf7 \strokec7 (\cf5 \strokec5 DISTINCT\cf4 \strokec4  \strokec6 q.question_id\cf7 \strokec7 ))\cf4 \strokec4  \cf5 \strokec5 AS\cf4 \strokec4  \strokec6 avg_answers_per_question\strokec4 ,\cb1 \
\cb3     \cf5 \strokec5 SAFE_DIVIDE\cf7 \strokec7 (\cf5 \strokec5 SUM\cf7 \strokec7 (\cf4 \strokec6 q.has_accepted_answer\cf7 \strokec7 )\cf4 \strokec4 , \cf5 \strokec5 COUNT\cf7 \strokec7 (\cf5 \strokec5 DISTINCT\cf4 \strokec4  \strokec6 q.question_id\cf7 \strokec7 ))\cf4 \strokec4  \cf5 \strokec5 AS\cf4 \strokec4  \strokec6 accepted_answer_rate\cb1 \strokec4 \
\cb3   \cf5 \strokec5 FROM\cf4 \strokec4  \strokec6 questions_with_answers\strokec4  \strokec6 q\strokec4 ,\cb1 \
\cb3   \cf5 \strokec5 UNNEST\cf7 \strokec7 (\cf4 \strokec6 q.tag_array\cf7 \strokec7 )\cf4 \strokec4  \cf5 \strokec5 AS\cf4 \strokec4  \strokec6 t1\strokec4 ,\cb1 \
\cb3   \cf5 \strokec5 UNNEST\cf7 \strokec7 (\cf4 \strokec6 q.tag_array\cf7 \strokec7 )\cf4 \strokec4  \cf5 \strokec5 AS\cf4 \strokec4  \strokec6 t2\cb1 \strokec4 \
\cb3   \cf5 \strokec5 WHERE\cf4 \strokec4  \strokec6 t1\strokec4  \cf7 \strokec7 <\cf4 \strokec4  \strokec6 t2\cb1 \strokec4 \
\cb3   \cf5 \strokec5 GROUP\cf4 \strokec4  \cf5 \strokec5 BY\cf4 \strokec4  \strokec6 tag_label\cb1 \strokec4 \
\cb3   \cf5 \strokec5 HAVING\cf4 \strokec4  \strokec6 total_questions\strokec4  \cf7 \strokec7 >=\cf4 \strokec4  \cf9 \strokec9 10\cf4 \cb1 \strokec4 \
\pard\pardeftab720\partightenfactor0
\cf7 \cb3 \strokec7 )\cf4 \strokec4 ,\cb1 \
\
\pard\pardeftab720\partightenfactor0
\cf2 \cb3 \strokec2 -- -------------------------------\cf4 \cb1 \strokec4 \
\cf2 \cb3 \strokec2 -- Step 8: Rank tags and tag-pairs by performance\cf4 \cb1 \strokec4 \
\cf2 \cb3 \strokec2 -- -------------------------------\cf4 \cb1 \strokec4 \
\pard\pardeftab720\partightenfactor0
\cf4 \cb3 \strokec6 ranked_metrics\strokec4  \cf5 \strokec5 AS\cf4 \strokec4  \cf7 \strokec7 (\cf4 \cb1 \strokec4 \
\pard\pardeftab720\partightenfactor0
\cf4 \cb3   \cf5 \strokec5 SELECT\cf4 \cb1 \strokec4 \
\cb3     \strokec6 tag_label\strokec4 ,\cb1 \
\cb3     \strokec6 total_questions\strokec4 ,\cb1 \
\cb3     \cf5 \strokec5 ROUND\cf7 \strokec7 (\cf4 \strokec6 avg_answers_per_question\strokec4 , \cf9 \strokec9 2\cf7 \strokec7 )\cf4 \strokec4  \cf5 \strokec5 AS\cf4 \strokec4  \strokec6 avg_answers_per_question\strokec4 ,\cb1 \
\cb3     \cf5 \strokec5 ROUND\cf7 \strokec7 (\cf4 \strokec6 accepted_answer_rate\strokec4 , \cf9 \strokec9 2\cf7 \strokec7 )\cf4 \strokec4  \cf5 \strokec5 AS\cf4 \strokec4  \strokec6 accepted_answer_rate\strokec4 ,\cb1 \
\cb3     \cf5 \strokec5 RANK\cf7 \strokec7 ()\cf4 \strokec4  \cf5 \strokec5 OVER\cf4 \strokec4  \cf7 \strokec7 (\cf5 \strokec5 ORDER\cf4 \strokec4  \cf5 \strokec5 BY\cf4 \strokec4  \strokec6 accepted_answer_rate\strokec4  \cf5 \strokec5 DESC\cf4 \strokec4 , \strokec6 avg_answers_per_question\strokec4  \cf5 \strokec5 DESC\cf7 \strokec7 )\cf4 \strokec4  \cf5 \strokec5 AS\cf4 \strokec4  \strokec6 best_rank\strokec4 ,\cb1 \
\cb3     \cf5 \strokec5 RANK\cf7 \strokec7 ()\cf4 \strokec4  \cf5 \strokec5 OVER\cf4 \strokec4  \cf7 \strokec7 (\cf5 \strokec5 ORDER\cf4 \strokec4  \cf5 \strokec5 BY\cf4 \strokec4  \strokec6 accepted_answer_rate\strokec4  \cf5 \strokec5 ASC\cf4 \strokec4 , \strokec6 avg_answers_per_question\strokec4  \cf5 \strokec5 ASC\cf7 \strokec7 )\cf4 \strokec4  \cf5 \strokec5 AS\cf4 \strokec4  \strokec6 worst_rank\strokec4 ,\cb1 \
\cb3     \cf8 \strokec8 'single_tag'\cf4 \strokec4  \cf5 \strokec5 AS\cf4 \strokec4  \strokec6 ranking_scope\cb1 \strokec4 \
\cb3   \cf5 \strokec5 FROM\cf4 \strokec4  \strokec6 tag_metrics\cb1 \strokec4 \
\cb3   \cf5 \strokec5 UNION\cf4 \strokec4  \cf5 \strokec5 ALL\cf4 \cb1 \strokec4 \
\cb3   \cf5 \strokec5 SELECT\cf4 \cb1 \strokec4 \
\cb3     \strokec6 tag_label\strokec4 ,\cb1 \
\cb3     \strokec6 total_questions\strokec4 ,\cb1 \
\cb3     \cf5 \strokec5 ROUND\cf7 \strokec7 (\cf4 \strokec6 avg_answers_per_question\strokec4 , \cf9 \strokec9 2\cf7 \strokec7 )\cf4 \strokec4 ,\cb1 \
\cb3     \cf5 \strokec5 ROUND\cf7 \strokec7 (\cf4 \strokec6 accepted_answer_rate\strokec4 , \cf9 \strokec9 2\cf7 \strokec7 )\cf4 \strokec4 ,\cb1 \
\cb3     \cf5 \strokec5 RANK\cf7 \strokec7 ()\cf4 \strokec4  \cf5 \strokec5 OVER\cf4 \strokec4  \cf7 \strokec7 (\cf5 \strokec5 ORDER\cf4 \strokec4  \cf5 \strokec5 BY\cf4 \strokec4  \strokec6 accepted_answer_rate\strokec4  \cf5 \strokec5 DESC\cf4 \strokec4 , \strokec6 avg_answers_per_question\strokec4  \cf5 \strokec5 DESC\cf7 \strokec7 )\cf4 \strokec4 ,\cb1 \
\cb3     \cf5 \strokec5 RANK\cf7 \strokec7 ()\cf4 \strokec4  \cf5 \strokec5 OVER\cf4 \strokec4  \cf7 \strokec7 (\cf5 \strokec5 ORDER\cf4 \strokec4  \cf5 \strokec5 BY\cf4 \strokec4  \strokec6 accepted_answer_rate\strokec4  \cf5 \strokec5 ASC\cf4 \strokec4 , \strokec6 avg_answers_per_question\strokec4  \cf5 \strokec5 ASC\cf7 \strokec7 )\cf4 \strokec4 ,\cb1 \
\cb3     \cf8 \strokec8 'tag_pair'\cf4 \strokec4  \cf5 \strokec5 AS\cf4 \strokec4  \strokec6 ranking_scope\cb1 \strokec4 \
\cb3   \cf5 \strokec5 FROM\cf4 \strokec4  \strokec6 tag_pair_metrics\cb1 \strokec4 \
\pard\pardeftab720\partightenfactor0
\cf7 \cb3 \strokec7 )\cf4 \strokec4 ,\cb1 \
\
\pard\pardeftab720\partightenfactor0
\cf2 \cb3 \strokec2 -- -------------------------------\cf4 \cb1 \strokec4 \
\cf2 \cb3 \strokec2 -- Step 9: Select top and bottom performers per scope\cf4 \cb1 \strokec4 \
\cf2 \cb3 \strokec2 -- -------------------------------\cf4 \cb1 \strokec4 \
\pard\pardeftab720\partightenfactor0
\cf4 \cb3 \strokec6 final_ranked\strokec4  \cf5 \strokec5 AS\cf4 \strokec4  \cf7 \strokec7 (\cf4 \cb1 \strokec4 \
\pard\pardeftab720\partightenfactor0
\cf4 \cb3   \cf5 \strokec5 SELECT\cf4 \cb1 \strokec4 \
\cb3     \strokec6 ranking_scope\strokec4 ,\cb1 \
\cb3     \cf8 \strokec8 'top'\cf4 \strokec4  \cf5 \strokec5 AS\cf4 \strokec4  \strokec6 ranking_type\strokec4 ,\cb1 \
\cb3     \strokec6 tag_label\strokec4 ,\cb1 \
\cb3     \strokec6 total_questions\strokec4 ,\cb1 \
\cb3     \strokec6 avg_answers_per_question\strokec4 ,\cb1 \
\cb3     \strokec6 accepted_answer_rate\strokec4 ,\cb1 \
\cb3     \strokec6 best_rank\strokec4  \cf5 \strokec5 AS\cf4 \strokec4  \strokec6 rank_order\cb1 \strokec4 \
\cb3   \cf5 \strokec5 FROM\cf4 \strokec4  \strokec6 ranked_metrics\cb1 \strokec4 \
\cb3   \cf5 \strokec5 WHERE\cf4 \strokec4  \strokec6 best_rank\strokec4  \cf7 \strokec7 <=\cf4 \strokec4  \cf9 \strokec9 10\cf4 \cb1 \strokec4 \
\cb3   \cf5 \strokec5 UNION\cf4 \strokec4  \cf5 \strokec5 ALL\cf4 \cb1 \strokec4 \
\cb3   \cf5 \strokec5 SELECT\cf4 \cb1 \strokec4 \
\cb3     \strokec6 ranking_scope\strokec4 ,\cb1 \
\cb3     \cf8 \strokec8 'bottom'\cf4 \strokec4  \cf5 \strokec5 AS\cf4 \strokec4  \strokec6 ranking_type\strokec4 ,\cb1 \
\cb3     \strokec6 tag_label\strokec4 ,\cb1 \
\cb3     \strokec6 total_questions\strokec4 ,\cb1 \
\cb3     \strokec6 avg_answers_per_question\strokec4 ,\cb1 \
\cb3     \strokec6 accepted_answer_rate\strokec4 ,\cb1 \
\cb3     \strokec6 worst_rank\strokec4  \cf5 \strokec5 AS\cf4 \strokec4  \strokec6 rank_order\cb1 \strokec4 \
\cb3   \cf5 \strokec5 FROM\cf4 \strokec4  \strokec6 ranked_metrics\cb1 \strokec4 \
\cb3   \cf5 \strokec5 WHERE\cf4 \strokec4  \strokec6 worst_rank\strokec4  \cf7 \strokec7 <=\cf4 \strokec4  \cf9 \strokec9 10\cf4 \cb1 \strokec4 \
\pard\pardeftab720\partightenfactor0
\cf7 \cb3 \strokec7 )\cf4 \cb1 \strokec4 \
\
\pard\pardeftab720\partightenfactor0
\cf2 \cb3 \strokec2 -- -------------------------------\cf4 \cb1 \strokec4 \
\cf2 \cb3 \strokec2 -- Step 10: Final Output\cf4 \cb1 \strokec4 \
\cf2 \cb3 \strokec2 -- -------------------------------\cf4 \cb1 \strokec4 \
\pard\pardeftab720\partightenfactor0
\cf5 \cb3 \strokec5 SELECT\cf4 \cb1 \strokec4 \
\pard\pardeftab720\partightenfactor0
\cf4 \cb3   \strokec6 ranking_scope\strokec4 ,\cb1 \
\cb3   \strokec6 ranking_type\strokec4 ,\cb1 \
\cb3   \strokec6 tag_label\strokec4 ,\cb1 \
\cb3   \strokec6 total_questions\strokec4 ,\cb1 \
\cb3   \strokec6 avg_answers_per_question\strokec4 ,\cb1 \
\cb3   \strokec6 accepted_answer_rate\strokec4 ,\cb1 \
\cb3   \strokec6 rank_order\strokec4  \cf5 \strokec5 AS\cf4 \strokec4  \strokec6 rank_position\cb1 \strokec4 \
\pard\pardeftab720\partightenfactor0
\cf5 \cb3 \strokec5 FROM\cf4 \strokec4  \strokec6 final_ranked\cb1 \strokec4 \
\cf5 \cb3 \strokec5 ORDER\cf4 \strokec4  \cf5 \strokec5 BY\cf4 \cb1 \strokec4 \
\pard\pardeftab720\partightenfactor0
\cf4 \cb3   \strokec6 ranking_scope\strokec4 ,\cb1 \
\cb3   \cf5 \strokec5 CASE\cf4 \strokec4  \strokec6 ranking_type\strokec4  \cf5 \strokec5 WHEN\cf4 \strokec4  \cf8 \strokec8 'top'\cf4 \strokec4  \cf5 \strokec5 THEN\cf4 \strokec4  \cf9 \strokec9 1\cf4 \strokec4  \cf5 \strokec5 ELSE\cf4 \strokec4  \cf9 \strokec9 2\cf4 \strokec4  \cf5 \strokec5 END\cf4 \strokec4 ,\cb1 \
\cb3   \strokec6 rank_order\strokec4 ;\cb1 \
\
}