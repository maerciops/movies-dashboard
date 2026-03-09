CREATE OR REPLACE VIEW `gold_data.vw_user_activity` AS
SELECT
  r.userId,
  COUNT(*) AS totalRatings,
  ROUND(AVG(r.rating), 2) AS avgRating,
  MIN(r.ratedAt) AS firstRating,
  MAX(r.ratedAt) AS lastRating
FROM `silver_data.fact_ratings` r  
WHERE r.rating IS NOT NULL
GROUP BY
  r.userId;