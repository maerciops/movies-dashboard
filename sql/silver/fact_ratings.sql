CREATE OR REPLACE TABLE `silver_data.fact_ratings` AS
SELECT 
  SAFE_CAST(userId AS INT64) AS userId,
  SAFE_CAST(movieId AS INT64) AS movieId,
  NULLIF(ROUND(SAFE_CAST(REPLACE(rating, ',', '.') AS FLOAT64), 2), -1) AS rating,
  SAFE_CAST(tstamp AS TIMESTAMP) AS ratedAt
FROM
  `raw_data.ext_user_rating_history`
UNION ALL
SELECT 
  SAFE_CAST(userId AS INT64) AS userId,
  SAFE_CAST(movieId AS INT64) AS movieId,
  NULLIF(ROUND(SAFE_CAST(REPLACE(rating, ',', '.') AS FLOAT64), 2), -1) AS rating,
  SAFE_CAST(tstamp AS TIMESTAMP) AS ratedAt
FROM
  `raw_data.ext_ratings_for_additional_users`
UNION ALL
SELECT 
  SAFE_CAST(userId AS INT64) AS userId,
  SAFE_CAST(movieId AS INT64) AS movieId,
  NULLIF(ROUND(SAFE_CAST(REPLACE(predictedRating, ',', '.') AS FLOAT64), 2), -1) AS rating,
  TIMESTAMP_SECONDS(SAFE_CAST(tstamp AS INT64)) AS ratedAt
FROM
  `raw_data.ext_user_recommendation_history`;