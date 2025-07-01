#!/bin/sh
set -e

TOKEN=$1
NAMESPACE=$2

check_repo() {
  local repo_name=$1
  http_code=$(curl -s -o /dev/null -w "%{http_code}" -H "Authorization: JWT $TOKEN" \
    "https://hub.docker.com/v2/repositories/$NAMESPACE/$repo_name/")
  if [ "$http_code" = "200" ]; then
    echo "Repositorio $repo_name ya existe."
    return 0
  elif [ "$http_code" = "404" ]; then
    return 1
  else
    echo "Error verificando repositorio $repo_name (HTTP $http_code)"
    exit 1
  fi
}

create_repo() {
  local repo_name=$1
  if check_repo "$repo_name"; then
    echo "No se crea $repo_name porque ya existe."
  else
    echo "Creando repositorio $repo_name en Docker Hub..."
    http_code=$(curl -s -o /dev/null -w "%{http_code}" -X POST \
      -H "Content-Type: application/json" \
      -H "Authorization: JWT $TOKEN" \
      -d "{\"namespace\": \"$NAMESPACE\", \"name\": \"$repo_name\", \"is_private\": false, \"description\": \"$repo_name image\"}" \
      https://hub.docker.com/v2/repositories/)
    if [ "$http_code" = "201" ]; then
      echo "Repositorio $repo_name creado correctamente."
    else
      echo "Error creando repositorio $repo_name (HTTP $http_code)"
      exit 1
    fi
  fi
}

create_repo "backend-app"
create_repo "frontend-app"
