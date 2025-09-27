# Структура проекта Sausage Store

## Обзор

Проект представляет собой интернет-магазин "Сосисочная" с микросервисной архитектурой, развертываемый в Kubernetes с автоматическим CI/CD через GitHub Actions.

## Структура репозитория

```
sausage-store/
├── .github/workflows/          # GitHub Actions workflows
│   ├── deploy.yaml            # Основной workflow для деплоя
│   └── variables.yaml         # Документация по переменным
├── backend/                   # Java Spring Boot приложение
│   ├── src/                   # Исходный код
│   ├── Dockerfile             # Docker образ для backend
│   └── pom.xml               # Maven конфигурация
├── frontend/                  # Angular приложение
│   ├── src/                   # Исходный код
│   ├── Dockerfile             # Multi-stage Docker образ
│   └── package.json          # NPM зависимости
├── backend-report/            # Go приложение для отчетов
│   ├── app/                   # Исходный код
│   ├── Dockerfile             # Multi-stage Docker образ
│   └── go.mod                # Go модули
├── sausage-store-chart/       # Helm чарт
│   ├── Chart.yaml            # Основной чарт
│   ├── values.yaml           # Значения по умолчанию
│   └── charts/               # Сабчарты
│       ├── backend/          # Backend чарт
│       ├── frontend/         # Frontend чарт
│       ├── backend-report/   # Backend-report чарт
│       └── infra/            # Инфраструктурный чарт
├── migrations/               # SQL миграции
│   ├── V001__create_tables.sql
│   ├── V002__change_schema.sql
│   ├── V003__insert_data.sql
│   └── V004__create_index.sql
├── SETUP.md                  # Инструкции по настройке
├── kubeconfig.example.yaml   # Пример kubeconfig
└── README.md                 # Основная документация
```

## Компоненты системы

### Frontend (Angular + nginx)
- **Технологии**: Angular 6, TypeScript, nginx
- **Функции**: Пользовательский интерфейс магазина
- **Деплой**: Multi-stage Docker образ с nginx
- **Доступ**: Через Ingress с SSL

### Backend (Java Spring Boot)
- **Технологии**: Java, Spring Boot, Spring Data
- **Функции**: API для фронтенда, управление заказами
- **База данных**: PostgreSQL
- **Мониторинг**: Prometheus метрики на `/actuator/prometheus`

### Backend-report (Go)
- **Технологии**: Go, MongoDB
- **Функции**: Генерация отчетов, планировщик задач
- **База данных**: MongoDB
- **Масштабирование**: HPA (Horizontal Pod Autoscaler)

### Инфраструктура
- **PostgreSQL**: Основная база данных
- **MongoDB**: База данных для отчетов
- **Миграции**: Автоматическое выполнение SQL миграций

## CI/CD Pipeline

### GitHub Actions Workflow

1. **Trigger**: Push в main ветку
2. **Build**: Сборка всех Docker образов
3. **Push**: Публикация в GitHub Container Registry
4. **Deploy**: Развертывание в Kubernetes через Helm
5. **Migrations**: Выполнение миграций БД
6. **Tests**: Smoke tests для проверки здоровья

### Образы

- `ghcr.io/your-org/sausage-store/frontend:latest`
- `ghcr.io/your-org/sausage-store/backend:latest`
- `ghcr.io/your-org/sausage-store/backend-report:latest`

## Helm Chart

### Основной чарт
- **Chart.yaml**: Метаданные и зависимости
- **values.yaml**: Конфигурация по умолчанию

### Сабчарты
- **backend**: Deployment, Service, ConfigMap
- **frontend**: Deployment, Service, Ingress, ConfigMap
- **backend-report**: Deployment, Service, HPA, Secret
- **infra**: PostgreSQL, MongoDB, Migrations Job

## Миграции базы данных

### Порядок выполнения
1. **V001**: Создание базовых таблиц
2. **V002**: Добавление ограничений и индексов
3. **V003**: Вставка тестовых данных
4. **V004**: Создание дополнительных индексов

### Автоматизация
- Выполняются через Kubernetes Job
- Используют Helm hooks для автоматического запуска
- Backend ждет завершения миграций перед запуском

## Мониторинг и логирование

### Метрики
- Backend экспортирует Prometheus метрики
- HPA для автоматического масштабирования backend-report
- Health checks для всех компонентов

### Логи
- Доступны через `kubectl logs`
- Централизованное логирование через nginx

## Безопасность

### Секреты
- Пароли БД хранятся в Kubernetes Secrets
- GitHub Secrets для CI/CD
- Избегание hardcoded значений

### Сетевая безопасность
- Ingress с SSL/TLS
- Внутренние сервисы недоступны извне
- Правильная настройка Service Mesh

## Масштабирование

### Горизонтальное
- HPA для backend-report
- Возможность ручного масштабирования всех компонентов

### Вертикальное
- Настроенные лимиты ресурсов
- VPA можно включить для backend

## Разработка

### Локальная разработка
```bash
# Установка зависимостей
helm dependency update

# Локальный деплой
helm install sausage-store . --namespace sausage-store --create-namespace
```

### Тестирование
- Smoke tests в CI/CD
- Health checks для всех сервисов
- Автоматическая проверка миграций
