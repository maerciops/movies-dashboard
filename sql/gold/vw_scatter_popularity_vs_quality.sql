CREATE OR REPLACE VIEW `gold_data.vw_scatter_popularity_vs_quality` AS
SELECT
  m.movieId, m.title,
  COUNT(*) AS totalRatings,
  ROUND(AVG(r.rating), 2) AS avgRating
FROM `silver_data.fact_ratings` r
JOIN `silver_data.dim_movies` m ON m.movieId = r.movieId 
WHERE r.rating IS NOT NULL
GROUP BY
  m.movieId,
  m.title
HAVING totalRatings > 50;