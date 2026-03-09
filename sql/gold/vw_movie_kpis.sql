CREATE OR REPLACE VIEW `gold_data.vw_movie_kpis` AS
SELECT
  m.movieId, m.title, m.year, m.genres,
  COUNT(*) AS totalRatings,
  ROUND(AVG(r.rating), 2) AS avgRating,
  MAX(r.rating) AS bestRating,
  MIN(r.rating) AS worstRating
FROM `silver_data.fact_ratings` r
JOIN `silver_data.dim_movies` m ON r.movieId = m.movieId
WHERE r.rating IS NOT NULL
GROUP BY
  m.movieId,  
  m.title,
  m.year,
  m.genres;