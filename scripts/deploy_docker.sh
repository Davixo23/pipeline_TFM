#!/bin/bash
set -e

# Directorio donde están los archivos docker-compose.yml y demás
DEPLOY_DIR="/home/ubuntu"

cd "$DEPLOY_DIR"

# Verificar si docker-compose está instalado, si no, instalar (como antes)
if ! command -v docker-compose &> /dev/null
then
  echo "Docker Compose no encontrado. Instalando..."
  sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-linux-x86_64" -o /usr/local/bin/docker-compose
  sudo chmod +x /usr/local/bin/docker-compose
  echo "Docker Compose instalado correctamente."
else
  echo "Docker Compose ya está instalado."
fi

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

# Ejecutar docker-compose en el directorio correcto
docker-compose down || true
docker-compose pull
docker-compose up -d --build
