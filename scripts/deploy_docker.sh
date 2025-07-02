#!/bin/bash
set -e

# Función para instalar docker-compose si no está presente
install_docker_compose() {
  echo "Docker Compose no encontrado. Instalando..."

  # Descargar la última versión de docker-compose
  sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-linux-x86_64" -o /usr/local/bin/docker-compose

  # Dar permisos de ejecución
  sudo chmod +x /usr/local/bin/docker-compose

  echo "Docker Compose instalado correctamente."
}

# Verificar si docker-compose está instalado
if ! command -v docker-compose &> /dev/null
then
  install_docker_compose
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

# Detener y eliminar contenedores anteriores
docker-compose down || true

# Descargar imágenes actualizadas
docker-compose pull

# Levantar servicios
docker-compose up -d --build
