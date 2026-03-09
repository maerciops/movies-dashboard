source .env

echo "Criando a estrutura json para as tabelas externas"

cat > /tmp/ext_belief_data.json <<EOF
{ 
  "sourceFormat": "CSV",
  "sourceUris": ["gs://${BUCKET_NAME}/${FOLDER_NAME}/belief_data.csv"],
  "csvOptions": {
    "skipLeadingRows": 1
  },
  "schema": {
    "fields": [
      { "name": "userId",  "type": "STRING" },
      { "name": "movieId", "type": "STRING" },
      { "name": "isSeen",  "type": "STRING" },
      { "name": "watchDate",  "type": "STRING" },
      { "name": "userElicitRating",  "type": "STRING" },
      { "name": "userPredictRating",  "type": "STRING" },
      { "name": "userCertainty",  "type": "STRING" },
      { "name": "tstamp",  "type": "STRING" },      
      { "name": "movie_idx",  "type": "STRING" },
      { "name": "source",  "type": "STRING" },
      { "name": "systemPredictRating",  "type": "STRING" }
    ]
  }
}
EOF

cat > /tmp/ext_movie_elicitation_set.json <<EOF
{
  "sourceFormat": "CSV",
  "sourceUris": ["gs://${BUCKET_NAME}/${FOLDER_NAME}/movie_elicitation_set.csv"],
  "csvOptions": {
    "skipLeadingRows": 1
  },
  "schema": {
    "fields": [
      { "name": "movieId",  "type": "STRING" },
      { "name": "month_idx", "type": "STRING" },
      { "name": "source",  "type": "STRING" },
      { "name": "tstamp",  "type": "STRING" }
    ]
  }
}
EOF

cat > /tmp/ext_movies.json <<EOF
{
  "sourceFormat": "CSV",
  "sourceUris": ["gs://${BUCKET_NAME}/${FOLDER_NAME}/movies.csv"],
  "csvOptions": {
    "skipLeadingRows": 1
  },
  "schema": {
    "fields": [
      { "name": "movieId", "type": "STRING" },
      { "name": "title", "type": "STRING" },
      { "name": "genres", "type": "STRING" }
    ]
  }
}
EOF

cat > /tmp/ext_ratings_for_additional_users.json <<EOF
{
  "sourceFormat": "CSV",
  "sourceUris": ["gs://${BUCKET_NAME}/${FOLDER_NAME}/ratings_for_additional_users.csv"],
  "csvOptions": {
    "skipLeadingRows": 1
  },
  "schema": {
    "fields": [
      { "name": "userId",  "type": "STRING" },
      { "name": "movieId", "type": "STRING" },
      { "name": "rating",  "type": "STRING" },
      { "name": "tstamp",  "type": "STRING" }
    ]
  }
}
EOF

cat > /tmp/ext_user_rating_history.json <<EOF
{
  "sourceFormat": "CSV",
  "sourceUris": ["gs://${BUCKET_NAME}/${FOLDER_NAME}/user_rating_history.csv"],
  "csvOptions": {
    "skipLeadingRows": 1
  },
  "schema": {
    "fields": [
      { "name": "userId",  "type": "STRING" },
      { "name": "movieId", "type": "STRING" },
      { "name": "rating",  "type": "STRING" },
      { "name": "tstamp",  "type": "STRING" }
    ]
  }
}
EOF

cat > /tmp/ext_user_recommendation_history.json <<EOF
{
  "sourceFormat": "CSV",
  "sourceUris": ["gs://${BUCKET_NAME}/${FOLDER_NAME}/user_recommendation_history.csv"],
  "csvOptions": {
    "skipLeadingRows": 1
  },
  "schema": {
    "fields": [
      { "name": "userId",  "type": "STRING" },
      { "name": "tstamp", "type": "STRING" },
      { "name": "movieId",  "type": "STRING" },
      { "name": "predictedRating",  "type": "STRING" }
    ]
  }
}
EOF

echo "Criando tabelas externas na camada: $BRONZE_DATASET"

bq mk \
  --force \
  --external_table_definition=/tmp/ext_belief_data.json \
  ${BRONZE_DATASET}.ext_belief_data

bq mk \
  --force \
  --external_table_definition=/tmp/ext_movie_elicitation_set.json \
  ${BRONZE_DATASET}.ext_movie_elicitation_set

bq mk \
  --force \
  --external_table_definition=/tmp/ext_movies.json \
  ${BRONZE_DATASET}.ext_movies

bq mk \
  --force \
  --external_table_definition=/tmp/ext_ratings_for_additional_users.json \
  ${BRONZE_DATASET}.ext_ratings_for_additional_users

bq mk \
  --force \
  --external_table_definition=/tmp/ext_user_rating_history.json \
  ${BRONZE_DATASET}.ext_user_rating_history

bq mk \
  --force \
  --external_table_definition=/tmp/ext_user_recommendation_history.json \
  ${BRONZE_DATASET}.ext_user_recommendation_history        

echo "Tabelas Bronze criadas com sucesso!"