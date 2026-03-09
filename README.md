# 🎬 Movies Dashboard

> Transformar dados brutos de avaliações de filmes em insights estratégicos sobre comportamento de consumo, sazonalidade de engajamento e performance de catálogo.

---

## 🏗️ Arquitetura do Pipeline

```
GCS (Data)
      │
      ▼
BigQuery - External Tables (bronze_data)
      │
      ▼
BigQuery - Silver Layer (silver_data)
   dim_movies / fact_ratings
      │
      ▼
BigQuery - Gold Layer (gold_data)
   Views para consumo
      │
      ▼
Metabase (Docker)
   Dashboard interativo
```

### Camadas

| Camada | Dataset BigQuery | Descrição |
|--------|-----------------|-----------|
| Raw | `raw_data` | External tables apontando para CSVs no GCS |
| Silver | `silver_data` | Dados limpos, tipados e normalizados |
| Gold | `gold_data` | Views agregadas para consumo pelo Metabase |

---

## 🛠️ Tecnologias

| Tecnologia | Uso |
|-----------|-----|
| GCP (Google Cloud Platform) | Infraestrutura cloud |
| GCS (Google Cloud Storage) | Data Lake — armazenamento dos CSVs |
| BigQuery | Data Warehouse — transformação e views |
| Metabase | Visualização e dashboards |
| Docker | Containerização do Metabase |
| SQL (Standard SQL) | Transformação de dados e criação de views |

---

## 📁 Estrutura do Projeto

```
movies-dashboard/
├── data/                        # Arquivos CSV originais (amostra)
├── scripts/                     # Scripts .sh de automação
│   ├── run_pipeline_setup.sh    # Orquestrador principal
│   ├── setup_infra.sh           # Criação de datasets e buckets
│   ├── create_bronze_layer.sh   # External tables na camada Raw
│   └── create_silver_gold.sh    # Tabelas Silver e views Gold
├── sql/
│   ├── silver/                  # Queries de limpeza e normalização
│   └── gold/                    # Views finais para o Dashboard
├── excalidraw_flow.excalidraw   # Fluxo da pipeline
├── .env                         # Variáveis de ambiente do GCP (não versionado)
├── .env.example                 # Exemplo de variáveis necessárias
├── .gitignore
└── README.md
```

---

## ⚙️ Passos de Execução

### Pré-requisitos

- Arquivos baixados e descompactados na pasta data. URL: [https://grouplens.org/datasets/movielens/ml_belief_2024/]
- `gcloud` CLI instalado e autenticado
- `bq` CLI disponível
- Docker instalado (para o Metabase)
- Arquivo `.env` configurado (veja `.env.example`)

### Configuração do `.env`

```bash
PROJECT_ID=""
BUCKET_NAME=""
FOLDER_NAME=""
RAW_DATASET=""
SILVER_DATASET=""
GOLD_DATASET=""
```

### Executando o pipeline completo

```bash
chmod +x scripts/run_pipeline_setup.sh
./scripts/run_pipeline_setup.sh
```

O orquestrador executa na seguinte ordem:

1. `setup_infra.sh` — cria datasets no BigQuery e bucket no GCS
2. `create_bronze_layer.sh` — cria external tables apontando para os CSVs
3. `create_silver_gold.sh` — executa as transformações Silver e cria as views Gold

### Subindo o Metabase

```bash
docker run -d \
  -p 3000:3000 \
  --name metabase \
  metabase/metabase
```

Acesse `http://localhost:3000` e conecte ao BigQuery usando a service account JSON.

---

## 📊 Queries Principais

### Silver — `dim_movies`

```sql
CREATE OR REPLACE TABLE `silver_data.dim_movies` AS
SELECT DISTINCT
  SAFE_CAST(movieId AS INT64) AS movieId,
  COALESCE(REGEXP_EXTRACT(title, r'^(.*)\s\(\d{4}\)$'), title) AS title,
  genres,
  SAFE_CAST(REGEXP_EXTRACT(title, r'\((\d{4})\)') AS INT64) AS year
FROM
  `raw_data.ext_movies`;
```

### Silver — `fact_ratings`

Unificação dos ratings de 3 fontes distintas com limpeza e tipagem:

```sql
CREATE OR REPLACE TABLE `silver_data.fact_ratings` AS
SELECT 
  SAFE_CAST(userId AS INT64) AS userId,
  SAFE_CAST(movieId AS INT64) AS movieId,
  NULLIF(ROUND(SAFE_CAST(REPLACE(rating, ',', '.') AS FLOAT64), 2), -1) AS rating,
  SAFE_CAST(tstamp AS TIMESTAMP) AS ratedAt
FROM `raw_data.ext_user_rating_history`
UNION ALL
SELECT 
  SAFE_CAST(userId AS INT64) AS userId,
  SAFE_CAST(movieId AS INT64) AS movieId,
  NULLIF(ROUND(SAFE_CAST(REPLACE(rating, ',', '.') AS FLOAT64), 2), -1) AS rating,
  SAFE_CAST(tstamp AS TIMESTAMP) AS ratedAt
FROM `raw_data.ext_ratings_for_additional_users`
UNION ALL
SELECT 
  SAFE_CAST(userId AS INT64) AS userId,
  SAFE_CAST(movieId AS INT64) AS movieId,
  NULLIF(ROUND(SAFE_CAST(REPLACE(predictedRating, ',', '.') AS FLOAT64), 2), -1) AS rating,
  TIMESTAMP_SECONDS(SAFE_CAST(tstamp AS INT64)) AS ratedAt
FROM `raw_data.ext_user_recommendation_history`;
```

### Gold — `vw_movie_kpis`

```sql
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
GROUP BY m.movieId, m.title, m.year, m.genres;
```

### Gold — `vw_top_movies`

```sql
SELECT
  m.movieId, m.title, m.year,
  COUNT(*) AS totalRatings,
  ROUND(AVG(r.rating), 2) AS avgRating
FROM `silver_data.dim_movies` m
JOIN `silver_data.fact_ratings` r ON m.movieId = r.movieId 
WHERE r.rating IS NOT NULL
GROUP BY m.movieId, m.title, m.year
HAVING totalRatings > 500
ORDER BY avgRating DESC
LIMIT 10;
```

### Gold — `vw_ratings_heatmap`

```sql
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
```

### Gold — `vw_scatter_popularity_vs_quality`

```sql
CREATE OR REPLACE VIEW `gold_data.vw_scatter_popularity_vs_quality` AS
SELECT
  m.movieId, m.title,
  COUNT(*) AS totalRatings,
  ROUND(AVG(r.rating), 2) AS avgRating
FROM `silver_data.fact_ratings` r
JOIN `silver_data.dim_movies` m ON m.movieId = r.movieId 
WHERE r.rating IS NOT NULL
GROUP BY m.movieId, m.title
HAVING totalRatings > 50;
```

### Gold — `vw_user_activity`

```sql
CREATE OR REPLACE VIEW `gold_data.vw_user_activity` AS
SELECT
  r.userId,
  COUNT(*) AS totalRatings,
  ROUND(AVG(r.rating), 2) AS avgRating,
  MIN(r.ratedAt) AS firstRating,
  MAX(r.ratedAt) AS lastRating
FROM `silver_data.fact_ratings` r  
WHERE r.rating IS NOT NULL
GROUP BY r.userId;
```

### Gold — `vw_genre_performance`

```sql
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
GROUP BY genres;
```

---

## 📸 Dashboard

![Movies Dashboard](data/print_dashboard.png)

O dashboard é dividido em 3 abas no Metabase:

| Aba | Visualizações |
|-----|--------------|
| Filmes (Movies) | KPI cards, Top 10 filmes, Performance por gênero, Scatter Plot |
| Ratings (Avaliações) | Heatmap de atividade por dia/hora, Evolução temporal |
| Usuários (Users) | Atividade por usuário, distribuição de ratings |
