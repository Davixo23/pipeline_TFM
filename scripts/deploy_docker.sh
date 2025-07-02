#!/bin/bash
set -e

BACKEND_IMAGE=$1
FRONTEND_IMAGE=$2

# Actualizar imágenes en docker-compose.yml usando yq (asegúrate que yq esté instalado)
yq e -i ".services.backend.image = \"$BACKEND_IMAGE\"" docker-compose.yml
yq e -i ".services.frontend.image = \"$FRONTEND_IMAGE\"" docker-compose.yml

# Detener y eliminar contenedores anteriores (si existen)
docker-compose down || true

# Descargar las imágenes actualizadas
docker-compose pull

# Levantar los servicios
docker-compose up -d --build
