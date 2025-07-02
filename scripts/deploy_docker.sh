#!/bin/bash
set -e

DEPLOY_DIR="/home/ubuntu"

echo "Cambiando al directorio de despliegue: $DEPLOY_DIR"
cd "$DEPLOY_DIR"

# Verificar si docker-compose está instalado, si no, instalarlo
if ! command -v docker-compose &> /dev/null; then
  echo "Docker Compose no encontrado. Instalando..."
  sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-linux-x86_64" -o /usr/local/bin/docker-compose
  sudo chmod +x /usr/local/bin/docker-compose
  echo "Docker Compose instalado correctamente."
else
  echo "Docker Compose ya está instalado."
fi

# Renombrar archivo temporal a docker-compose.yml si existe
if [ -f docker-compose.temp.yml ]; then
  echo "Renombrando docker-compose.temp.yml a docker-compose.yml..."
  mv -f docker-compose.temp.yml docker-compose.yml
fi

# Detener y eliminar contenedores anteriores (si existen)
echo "Deteniendo contenedores existentes..."
docker-compose down || echo "No se pudieron detener contenedores o no existían."

# Descargar imágenes actualizadas
echo "Descargando imágenes actualizadas..."
docker-compose pull

# Levantar servicios con construcción si es necesario
echo "Levantando servicios..."
docker-compose up -d --build

echo "Despliegue completado con éxito."
