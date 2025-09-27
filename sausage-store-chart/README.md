# Sausage Store Helm Chart

Этот Helm-чарт развертывает интернет-магазин "Сосисочная" в кластере Kubernetes с автоматическим деплоем через GitHub Actions.

## Компоненты

- **frontend** - Angular приложение с nginx
- **backend** - Java Spring Boot приложение
- **backend-report** - Go приложение для генерации отчетов
- **infra** - PostgreSQL и MongoDB базы данных + миграции

## Автоматический деплой

Приложение автоматически деплоится при пуше в `main` ветку через GitHub Actions:

1. **Сборка образов** - собираются все три компонента
2. **Публикация в GitHub Container Registry** - образы публикуются в `ghcr.io`
3. **Деплой в Kubernetes** - Helm чарт развертывается с новыми образами
4. **Выполнение миграций** - автоматически выполняются миграции БД
5. **Проверка здоровья** - выполняются smoke tests

## Настройка

См. [SETUP.md](../SETUP.md) для настройки GitHub Secrets и окружения.

## Настройка Nexus

См. [NEXUS_SETUP.md](../NEXUS_SETUP.md) для настройки Helm репозитория в Nexus.

## Локальная установка

1. Установите зависимости:
   ```bash
   helm dependency update
   ```

2. Установите релиз:
   ```bash
   helm install sausage-store . --namespace sausage-store --create-namespace \
     --set frontend.ingress.host=localhost
   ```

## Миграции

Миграции базы данных выполняются автоматически при установке/обновлении через Job. Миграции включают:

- V001: Создание таблиц
- V002: Изменение схемы и добавление ограничений
- V003: Вставка тестовых данных
- V004: Создание индексов

## Конфигурация

### Frontend
- Использует nginx для раздачи статики
- Настроен прокси для API запросов к backend
- Поддерживает Ingress для внешнего доступа

### Backend
- Подключается к PostgreSQL
- Настроены health checks
- Использует RollingUpdate стратегию

### Backend-report
- Подключается к MongoDB
- Настроен HPA для автоматического масштабирования
- Использует Recreate стратегию

### Инфраструктура
- PostgreSQL с персистентным хранилищем
- MongoDB с персистентным хранилищем
- Автоматическое выполнение миграций

## Мониторинг

Backend экспортирует метрики Prometheus на `/actuator/prometheus`.

## Масштабирование

### Автоматическое масштабирование

- **Backend**: VPA (Vertical Pod Autoscaler) в режиме рекомендаций для CPU и памяти
- **Backend-report**: HPA (Horizontal Pod Autoscaler) для автоматического масштабирования по CPU и памяти

### Ручное масштабирование

```bash
# Масштабирование backend
kubectl scale deployment sausage-store-backend --replicas=3 -n sausage-store

# Проверка HPA для backend-report
kubectl get hpa -n sausage-store

# Проверка VPA для backend
kubectl get vpa -n sausage-store
```

## Стратегии деплоя

- **Backend**: RollingUpdate с maxUnavailable=1, maxSurge=1
- **Backend-report**: Recreate (для приложений с состоянием)
- **Frontend**: Recreate (для статических файлов)

## Health Checks

- **Backend**: LivenessProbe и ReadinessProbe на `/actuator/health:8080`
- **Frontend**: LivenessProbe и ReadinessProbe на `/`
- **Backend-report**: LivenessProbe и ReadinessProbe на `/health`
