#!/bin/bash
set -e
echo "Instalando SHIELDGUARD PRO..."

if command -v apt-get >/dev/null 2>&1; then
  sudo apt-get update
  sudo apt-get install -y docker.io docker-compose-plugin || sudo apt-get install -y docker-compose
else
  echo "Nota: instala Docker y Docker Compose manualmente si no usas Debian/Ubuntu."
fi

docker compose version >/dev/null 2>&1 || echo "Usando docker-compose"

echo "Construyendo imágenes..."
if docker compose version >/dev/null 2>&1; then
  docker compose build
else
  docker-compose build
fi

echo "¡Listo! Ejecuta: docker compose up -d (o docker-compose up -d)"

