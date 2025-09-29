# Инструкции по развертыванию Sausage Store

## Описание сервисов

- **frontend** — Angular приложение с пользовательским интерфейсом
- **backend** — Java Spring Boot сервис для управления товарами и заказами
- **backend-report** — Go сервис для генерации отчетов
- **PostgreSQL** — база данных для товаров и заказов
- **MongoDB** — база данных для отчетов

## Локальная разработка

### Запуск через Docker Compose

```bash
# Создайте файл .env с вашими настройками
echo "DOCKER_USERNAME=your-docker-username" > .env
echo "VERSION=latest" >> .env

# Запуск всех сервисов
docker-compose up -d

# Просмотр логов
docker-compose logs -f

# Остановка сервисов
docker-compose down
```

### Запуск с локальной сборкой

```bash
# Для локальной разработки с пересборкой образов
docker-compose -f docker-compose.local.yml up --build -d
```

### Выполнение миграций

```bash
# Выполнение миграций локально
./scripts/migrate.sh localhost 5432 sausage_store postgres password
```

## Сборка и публикация образов

### Автоматическая сборка через скрипт

```bash
# Вход в Docker Hub
docker login

# Сборка и публикация всех образов
./scripts/build-and-push.sh your-docker-username latest
```

### Ручная сборка образов

```bash
# Backend
docker build -t your-username/sausage-store-backend:latest ./backend

# Frontend
docker build -t your-username/sausage-store-frontend:latest ./frontend

# Backend-report
docker build -t your-username/sausage-store-backend-report:latest ./backend-report

# Публикация
docker push your-username/sausage-store-backend:latest
docker push your-username/sausage-store-frontend:latest
docker push your-username/sausage-store-backend-report:latest
```

## GitHub Actions

### Настройка секретов

В настройках репозитория GitHub добавьте следующие секреты:

- `DOCKER_USERNAME` — ваш логин в Docker Hub
- `DOCKER_PASSWORD` — ваш пароль/токен Docker Hub

### Автоматический деплой

Пайплайн автоматически:
1. Собирает образы при пуше в main ветку
2. Публикует их в Docker Hub с тегом `latest`
3. Пытается загрузить образы из Docker Hub
4. Если образы не найдены, собирает их локально
5. Деплоит локально через Docker Compose
6. Выполняет миграции базы данных

**Примечание:** 
- Kubernetes деплой закомментирован. Для локального деплоя используется Docker Compose
- Образы публикуются с тегом `latest` для упрощения
- Если образы не найдены в Docker Hub, они будут собраны локально

## Структура миграций

Миграции находятся в папке `migrations/`:

- `V001__create_tables.sql` — создание таблиц
- `V002__change_schema.sql` — изменение схемы и добавление ограничений
- `V003__insert_data.sql` — вставка тестовых данных
- `V004__create_index.sql` — создание индексов

## Порты сервисов

- Frontend: 80
- Backend: 8080
- Backend-report: 8081
- PostgreSQL: 5432
- MongoDB: 27017

## Переменные окружения

### Backend
- `SPRING_DATASOURCE_URL` — URL PostgreSQL
- `SPRING_DATASOURCE_USERNAME` — пользователь PostgreSQL
- `SPRING_DATASOURCE_PASSWORD` — пароль PostgreSQL
- `SPRING_DATA_MONGODB_URI` — URI MongoDB

### Backend-report
- `MONGODB_URI` — URI MongoDB

## Мониторинг

Для проверки состояния сервисов:

```bash
# Проверка статуса контейнеров
docker-compose ps

# Проверка логов
docker-compose logs service-name

# Проверка здоровья сервисов
curl http://localhost:8080/actuator/health  # Backend
curl http://localhost:8081/health          # Backend-report
```
