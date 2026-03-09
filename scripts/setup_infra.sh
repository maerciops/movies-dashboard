if [ -f .env ]; then
    export $(grep -v '^#' .env | xargs)
else
    echo "Erro: Arquivo .env não encontrado!"
    exit 1
fi

echo "Iniciando setup da infraestrutura para o projeto: $GCP_PROJECT_ID"

gcloud config set project $GCP_PROJECT_ID
gsutil mb -l $GCP_REGION gs://$BUCKET_NAME || echo "Bucket já existe ou erro na criação."

bq mk --location=$GCP_REGION $BRONZE_DATASET || echo "Dataset Bronze já existe."
bq mk --location=$GCP_REGION $SILVER_DATASET || echo "Dataset Silver já existe."
bq mk --location=$GCP_REGION $GOLD_DATASET || echo "Dataset Gold já existe."

echo "Infraestrutura básica pronta!"
echo "Próximo passo: Fazer o upload dos CSVs para gs://$BUCKET_NAME/$FOLDER_NAME/"

gsutil -m cp data/*.csv gs://$BUCKET_NAME/$FOLDER_NAME/ || echo "Arquivos já existem ou aconteceu um erro no upload."

echo "Subindo Metabase via Docker..."
docker compose up -d
echo "Metabase disponível em: http://localhost:3000"