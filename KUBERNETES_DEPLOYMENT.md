# Kubernetes Deployment Guide

## Исправления для Helm чартов

### Проблема
Ошибка при упаковке Helm чарта: `Chart.yaml file is missing`

### Решение
Созданы недостающие файлы для всех чартов:

#### 1. Frontend Chart
- `Chart.yaml` - метаданные чарта
- `templates/deployment.yaml` - развертывание
- `templates/service.yaml` - сервис
- `templates/ingress.yaml` - Ingress с правильным доменом
- `templates/_helpers.tpl` - вспомогательные функции
- `values.yaml` - значения по умолчанию

#### 2. Backend Chart
- `Chart.yaml` - метаданные чарта
- `templates/deployment.yaml` - развертывание с RollingUpdate стратегией
- `templates/service.yaml` - сервис
- `templates/configmap.yaml` - конфигурация
- `templates/vpa.yaml` - вертикальное автомасштабирование
- `templates/_helpers.tpl` - вспомогательные функции

#### 3. Backend-report Chart
- `Chart.yaml` - метаданные чарта
- `templates/deployment.yaml` - развертывание с Recreate стратегией
- `templates/service.yaml` - сервис
- `templates/hpa.yaml` - горизонтальное автомасштабирование
- `templates/_helpers.tpl` - вспомогательные функции
- `values.yaml` - значения по умолчанию

#### 4. Infra Chart
- `Chart.yaml` - метаданные чарта
- `templates/postgresql.yaml` - PostgreSQL с PVC
- `templates/mongodb.yaml` - MongoDB
- `templates/mongodb-init-job.yaml` - Job для инициализации MongoDB
- `templates/_helpers.tpl` - вспомогательные функции

### Исправления в GitHub Actions

#### Проблема с упаковкой
- Файл чарта создается как `sausage-store-0.1.0.tgz`, а не `sausage-store-chart-*.tgz`
- Исправлен поиск файла в скрипте загрузки

#### Добавлена очистка ресурсов
- Удаление существующих Helm релизов
- Очистка ресурсов по лейблам
- Проверка статуса после деплоя

### Команды для локального тестирования

```bash
# Обновление зависимостей
cd sausage-store-chart
helm dependency update
helm dependency build

# Упаковка чарта
helm package .

# Проверка содержимого
tar -tzf sausage-store-0.1.0.tgz

# Очистка тестового файла
rm sausage-store-0.1.0.tgz
```

### Необходимые секреты в GitHub

- `DOCKER_USERNAME` - логин Docker Hub
- `DOCKER_PASSWORD` - пароль Docker Hub
- `NEXUS_HELM_REPO` - URL репозитория Nexus
- `NEXUS_HELM_REPO_USER` - пользователь Nexus
- `NEXUS_HELM_REPO_PASSWORD` - пароль Nexus
- `KUBE_CONFIG` - конфигурация Kubernetes (base64)

### Структура деплоя

1. **Build & Push** - сборка и публикация образов в Docker Hub
2. **Add Helm Chart to Nexus** - упаковка и загрузка чарта в Nexus
3. **Deploy to Kubernetes** - деплой в кластер с очисткой старых ресурсов

### Особенности

- **RollingUpdate** для backend и frontend
- **Recreate** для backend-report
- **VPA** для backend (режим рекомендаций)
- **HPA** для backend-report
- **LivenessProbe** для всех сервисов
- **PostgreSQL** с persistent storage (10Gi)
- **MongoDB** с автоматической инициализацией
- **Ingress** с TLS сертификатом
