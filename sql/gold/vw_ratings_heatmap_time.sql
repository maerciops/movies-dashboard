CREATE OR REPLACE VIEW `gold_data.vw_ratings_heatmap_time` AS
SELECT
  EXTRACT(YEAR FROM r.ratedAt) AS yearRating,
  FORMAT_TIMESTAMP('%Y-%m', r.ratedAt) AS monthRating,
  COUNT(*) AS totalRatings,
  ROUND(AVG(r.rating), 2) AS avgRating
FROM `silver_data.fact_ratings` r
GROUP BY 
  yearRating, 
  monthRating;