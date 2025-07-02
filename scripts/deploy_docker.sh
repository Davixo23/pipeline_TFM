#!/bin/bash
set -e

# Variables opcionales si las usas, o solo asume que docker-compose.yml ya está en la VM

# Eliminar docker-compose.yml viejo si existe
if [ -f docker-compose.yml ]; then
  echo "Eliminando docker-compose.yml viejo..."
  rm -f docker-compose.yml
fi

# Renombrar el archivo temporal si existe
if [ -f docker-compose.temp.yml ]; then
  echo "Renombrando docker-compose.temp.yml a docker-compose.yml..."
  mv docker-compose.temp.yml docker-compose.yml
fi

# Detener y eliminar contenedores anteriores
docker-compose down || true

# Descargar imágenes actualizadas
docker-compose pull

# Levantar servicios
docker-compose up -d --build
