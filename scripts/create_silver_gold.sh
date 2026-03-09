set -e
source .env

echo "Iniciando Pipeline de Dados..."

echo "Transformando Camada Silver..."
bq query --use_legacy_sql=false < sql/silver/dim_movies.sql
bq query --use_legacy_sql=false < sql/silver/fact_ratings.sql

echo "Criando Views da Camada Gold..."
bq query --use_legacy_sql=false < sql/gold/vw_genre_performance.sql
bq query --use_legacy_sql=false < sql/gold/vw_user_activity.sql
bq query --use_legacy_sql=false < sql/gold/vw_top_movies.sql
bq query --use_legacy_sql=false < sql/gold/vw_ratings_heatmap_time.sql
bq query --use_legacy_sql=false < sql/gold/vw_ratings_heatmap.sql
bq query --use_legacy_sql=false < sql/gold/vw_scatter_popularity_vs_quality.sql
bq query --use_legacy_sql=false < sql/gold/vw_movie_kpis.sql

echo "✅ Tudo pronto!"