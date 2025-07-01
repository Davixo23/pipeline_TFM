#!/bin/sh
set -e

TOKEN=$1
NAMESPACE=$2

create_repo() {
  local repo_name=$1
  echo "Creando repositorio $repo_name en Docker Hub..."
  http_code=$(curl -s -o /dev/null -w "%{http_code}" -X POST \
    -H "Content-Type: application/json" \
    -H "Authorization: JWT $TOKEN" \
    -d "{\"namespace\": \"$NAMESPACE\", \"name\": \"$repo_name\", \"is_private\": false, \"description\": \"$repo_name image\"}" \
    https://hub.docker.com/v2/repositories/)

  if [ "$http_code" = "201" ] || [ "$http_code" = "409" ]; then
    echo "Repositorio $repo_name creado o ya existe."
  else
    echo "Error creando repositorio $repo_name (HTTP $http_code)"
    exit 1
  fi
}

create_repo "backend-app"
create_repo "frontend-app"
