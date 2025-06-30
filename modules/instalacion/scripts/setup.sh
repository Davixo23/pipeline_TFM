#!/bin/bash
echo "Actualizando paquetes..."
sudo apt-get update -y
echo "Instalando Git..."
sudo apt-get install -y git
echo "Instalando Docker..."
sudo apt-get install -y docker.io
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker ubuntu # Asume usuario 'ubuntu', ajusta si es diferente

echo "Configurando iptables para HTTP (puerto 80)..."
# Permitir todo el tráfico de entrada. Esta es una configuración muy laxa.
# Para producción, se recomienda especificar puertos y fuentes.
sudo iptables -I INPUT -j ACCEPT
# Instalar iptables-persistent para guardar las reglas
echo "Instalando iptables-persistent..."
sudo apt-get install -y iptables-persistent
echo "Guardando reglas de iptables..."
sudo netfilter-persistent save

echo "Instalación y configuración completada."
