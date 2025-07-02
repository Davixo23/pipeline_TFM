#!/bin/bash
set -e

# Detener y eliminar contenedores anteriores
docker-compose down || true

# Descargar las imágenes
docker-compose pull

# Levantar servicios
docker-compose up -d --build
