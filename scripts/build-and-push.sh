#!/bin/bash

# Скрипт для сборки и публикации образов в Docker Hub
# Использование: ./build-and-push.sh <docker_username> <version>

set -e

DOCKER_USERNAME=${1:-"your-username"}
VERSION=${2:-"latest"}

echo "Сборка и публикация образов для пользователя: $DOCKER_USERNAME"
echo "Версия: $VERSION"

# Функция для сборки и публикации образа
build_and_push() {
    local service_name=$1
    local dockerfile_path=$2
    local context_path=$3
    
    echo "Сборка образа для $service_name..."
    
    # Сборка образа
    docker build -t $DOCKER_USERNAME/sausage-store-$service_name:$VERSION \
                 -f $dockerfile_path \
                 $context_path
    
    # Публикация образа
    echo "Публикация образа $service_name..."
    docker push $DOCKER_USERNAME/sausage-store-$service_name:$VERSION
    
    echo "Образ $service_name успешно собран и опубликован"
}

# Проверка авторизации в Docker Hub
echo "Проверка авторизации в Docker Hub..."
if ! docker info | grep -q "Username"; then
    echo "Ошибка: Необходимо войти в Docker Hub. Выполните: docker login"
    exit 1
fi

# Сборка и публикация всех сервисов
build_and_push "backend" "backend/Dockerfile" "backend"
build_and_push "frontend" "frontend/Dockerfile" "frontend"
build_and_push "backend-report" "backend-report/Dockerfile" "backend-report"

echo "Все образы успешно собраны и опубликованы в Docker Hub!"
echo ""
echo "Опубликованные образы:"
echo "- $DOCKER_USERNAME/sausage-store-backend:$VERSION"
echo "- $DOCKER_USERNAME/sausage-store-frontend:$VERSION"
echo "- $DOCKER_USERNAME/sausage-store-backend-report:$VERSION"
