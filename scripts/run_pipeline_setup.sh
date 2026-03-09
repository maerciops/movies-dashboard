#!/bin/bash
set -e

echo -e "Iniciando Pipeline do Movie Dashboard..."

echo -e "Step 1/3: Configurando Infraestrutura..."
bash scripts/setup_infra.sh

echo -e "Step 2/3: Carregando Camada Bronze..."
bash scripts/create_bronze_tables.sh

echo -e "Step 3/3: Executando Transformações Silver e Gold..."
bash scripts/create_silver_gold.sh

echo -e "Pipeline concluído com sucesso!"
echo -e "Acesse o Metabase em: http://localhost:3000"