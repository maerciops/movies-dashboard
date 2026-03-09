CREATE OR REPLACE VIEW `gold_data.vw_ratings_heatmap` AS
SELECT
  EXTRACT(DAYOFWEEK FROM r.ratedAt) AS diaSemanaNum,
  CASE EXTRACT(DAYOFWEEK FROM r.ratedAt)
  WHEN 2 THEN '1. Segunda'
  WHEN 3 THEN '2. Terça'
  WHEN 4 THEN '3. Quarta'
  WHEN 5 THEN '4. Quinta'
  WHEN 6 THEN '5. Sexta'
  WHEN 7 THEN '6. Sábado'
  WHEN 1 THEN '7. Domingo'
  END AS diaSemanaNome,
  EXTRACT(HOUR FROM r.ratedAt) AS horaDia,
  COUNT(*) AS totalRatings,
  ROUND(AVG(r.rating), 2) AS avgRating
FROM `silver_data.fact_ratings` r
GROUP BY 1, 2, 3
ORDER BY diaSemanaNum, horaDia;