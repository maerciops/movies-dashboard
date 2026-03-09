CREATE OR REPLACE TABLE `silver_data.dim_movies` AS
SELECT DISTINCT
  SAFE_CAST(movieId AS INT64) AS movieId,
  COALESCE(REGEXP_EXTRACT(title, r'^(.*)\s\(\d{4}\)$'), title) AS title,
  genres,
  SAFE_CAST(REGEXP_EXTRACT(title, r'\((\d{4})\)') AS INT64) AS year
FROM
  `raw_data.ext_movies`;