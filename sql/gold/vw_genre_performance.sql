CREATE OR REPLACE VIEW `gold_data.vw_genre_performance` AS
SELECT  
  genres,
  COUNT(*) AS totalRatings,
  ROUND(AVG(r.rating), 2) AS avgRating,
  COUNT(DISTINCT m.movieId) AS totalMovies
FROM `silver_data.dim_movies` m
CROSS JOIN UNNEST(SPLIT(m.genres, '|')) AS genres
JOIN `silver_data.fact_ratings` r ON m.movieId = r.movieId 
WHERE r.rating IS NOT NULL
GROUP BY
  genres;