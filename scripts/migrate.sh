#!/bin/bash

# Скрипт для выполнения миграций PostgreSQL
# Использование: ./migrate.sh <host> <port> <database> <username> <password>

set -e

HOST=${1:-localhost}
PORT=${2:-5432}
DATABASE=${3:-sausage_store}
USERNAME=${4:-postgres}
PASSWORD=${5:-password}

echo "Выполнение миграций для базы данных $DATABASE на $HOST:$PORT"

# Установка переменной окружения для пароля
export PGPASSWORD=$PASSWORD

# Выполнение миграций в порядке
MIGRATIONS_DIR="migrations"
MIGRATION_FILES=(
    "V001__create_tables.sql"
    "V002__change_schema.sql"
    "V003__insert_data.sql"
    "V004__create_index.sql"
)

for migration in "${MIGRATION_FILES[@]}"; do
    if [ -f "$MIGRATIONS_DIR/$migration" ]; then
        echo "Выполнение миграции: $migration"
        psql -h $HOST -p $PORT -U $USERNAME -d $DATABASE -f "$MIGRATIONS_DIR/$migration"
        echo "Миграция $migration выполнена успешно"
    else
        echo "Предупреждение: файл миграции $migration не найден"
    fi
done

echo "Все миграции выполнены успешно"
