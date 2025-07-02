#!/bin/bash
set -e

DEPLOY_DIR="/home/ubuntu"
cd "$DEPLOY_DIR"

echo "Actualizando sistema e instalando Nginx si no está instalado..."

if ! command -v nginx &> /dev/null; then
  sudo apt update
  sudo apt install -y nginx
  sudo systemctl enable nginx
  sudo systemctl start nginx
else
  echo "Nginx ya está instalado."

  if ! sudo systemctl is-enabled nginx &> /dev/null; then
    echo "Habilitando Nginx para iniciar en boot..."
    sudo systemctl enable nginx
  fi

  if ! sudo systemctl is-active nginx &> /dev/null; then
    echo "Iniciando servicio Nginx..."
    sudo systemctl start nginx
  fi
fi

echo "Eliminando configuraciones por defecto de Nginx para evitar conflictos..."

sudo rm -f /etc/nginx/sites-enabled/default
sudo rm -f /etc/nginx/sites-enabled/000-default || true

echo "Descargando imágenes Docker desde Docker Hub..."

docker pull davixo/backend-app:latest
docker pull davixo/frontend-app:latest

echo "Deteniendo y eliminando contenedores antiguos (si existen)..."

docker rm -f backend frontend || true

echo "Ejecutando contenedor backend en puerto 4000..."

docker run -d --name backend -p 4000:4000 davixo/backend-app:latest

echo "Ejecutando contenedor frontend en puerto 3000..."

docker run -d --name frontend -p 3000:3000 davixo/frontend-app:latest

echo "Creando configuración personalizada de Nginx para proxy inverso..."

NGINX_CONF_PATH="/etc/nginx/sites-available/my_app.conf"

sudo tee "$NGINX_CONF_PATH" > /dev/null <<'EOF'
server {
    listen 80;

    location / {
        proxy_pass http://localhost:3000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }

    location /api/ {
        proxy_pass http://localhost:4000/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
}
EOF

echo "Habilitando configuración personalizada de Nginx..."

sudo ln -sf "$NGINX_CONF_PATH" /etc/nginx/sites-enabled/my_app.conf

echo "Probando configuración de Nginx..."

sudo nginx -t

echo "Recargando Nginx para aplicar cambios..."

sudo systemctl reload nginx

echo "Despliegue completado con éxito."
