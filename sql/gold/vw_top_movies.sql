CREATE OR REPLACE VIEW `gold_data.vw_top_movies` AS
SELECT
  m.movieId, m.title, m.year,
  COUNT(*) AS totalRatings,
  ROUND(AVG(r.rating), 2) AS avgRating
FROM `silver_data.dim_movies` m
JOIN `silver_data.fact_ratings` r ON m.movieId = r.movieId 
WHERE r.rating IS NOT NULL
GROUP BY
  m.movieId,  
  m.title,
  m.year
HAVING totalRatings > 500
ORDER BY avgRating DESC
LIMIT 10;