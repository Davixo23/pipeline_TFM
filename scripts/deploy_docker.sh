#!/bin/bash
set -e

# Variables recibidas
BACKEND_IMAGE=$1
FRONTEND_IMAGE=$2

# Elimina contenedores anteriores si existen
docker rm -f backend || true
docker rm -f frontend || true

# Ejecuta backend con puerto 4000 mapeado
docker run -d --name backend -p 4000:4000 "$BACKEND_IMAGE"

# Ejecuta frontend con puerto 80 mapeado al 3000 interno
docker run -d --name frontend -p 80:3000 "$FRONTEND_IMAGE"
