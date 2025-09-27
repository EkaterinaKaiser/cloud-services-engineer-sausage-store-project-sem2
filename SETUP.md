# Настройка автоматического деплоя Sausage Store

## Предварительные требования

1. Kubernetes кластер (например, в Яндекс Облаке)
2. Настроенный kubectl для работы с кластером
3. GitHub репозиторий с кодом

## Настройка GitHub Secrets

В настройках репозитория (Settings → Secrets and variables → Actions) добавьте следующие секреты:

### Обязательные секреты:

1. **KUBE_CONFIG** - kubeconfig файл для доступа к кластеру
   ```bash
   # Получите kubeconfig из кластера
   kubectl config view --raw > kubeconfig.yaml
   # Добавьте содержимое файла как секрет KUBE_CONFIG
   ```

2. **DOCKER_USER** - имя пользователя Docker Hub
3. **DOCKER_PASSWORD** - пароль Docker Hub
4. **NEXUS_HELM_REPO** - URL репозитория Helm в Nexus
5. **NEXUS_HELM_REPO_USER** - пользователь для Nexus
6. **NEXUS_HELM_REPO_PASSWORD** - пароль для Nexus
7. **VAULT_TOKEN** - токен для Vault (если используется)

### Переменные окружения:

8. **SAUSAGE_STORE_NAMESPACE** - namespace для деплоя (например: `sausage-store`)
9. **INGRESS_HOST** - домен для Ingress (например: `your-hostname.students-projects.ru`)

### Дополнительные секреты (опционально):

10. **POSTGRES_PASSWORD** - пароль для PostgreSQL (по умолчанию: `storepassword`)
11. **MONGO_ROOT_PASSWORD** - пароль root для MongoDB (по умолчанию: `rootpassword`)

## Настройка окружения

1. Перейдите в Settings → Environments
2. Создайте окружение `production`
3. Настройте правила защиты (например, только из main ветки)
4. Добавьте секреты в это окружение

## Как работает деплой

### При пуше в main ветку:

1. **Сборка образов** - автоматически собираются все три образа:
   - `ghcr.io/your-org/sausage-store/frontend:latest`
   - `ghcr.io/your-org/sausage-store/backend:latest`
   - `ghcr.io/your-org/sausage-store/backend-report:latest`

2. **Публикация в GitHub Container Registry** - образы автоматически публикуются

3. **Деплой в Kubernetes** - Helm чарт развертывается с новыми образами

4. **Выполнение миграций** - автоматически выполняются миграции БД

5. **Проверка здоровья** - выполняются smoke tests

### При создании Pull Request:

- Только собираются образы (без деплоя)
- Можно проверить, что сборка проходит успешно

## Мониторинг деплоя

1. Перейдите в Actions вкладку GitHub репозитория
2. Отслеживайте статус workflow "Deploy Sausage Store to Kubernetes"
3. В случае ошибок проверьте логи в соответствующих шагах

## Откат изменений

В случае проблем можно откатиться к предыдущей версии:

```bash
# Получить список релизов
helm history sausage-store -n sausage-store

# Откатиться к предыдущей версии
helm rollback sausage-store 1 -n sausage-store
```

## Локальная разработка

Для локальной разработки используйте:

```bash
# Установка зависимостей
cd sausage-store-chart
helm dependency update

# Локальная установка
helm install sausage-store . --namespace sausage-store --create-namespace \
  --set frontend.ingress.host=localhost \
  --set global.imagePullPolicy=IfNotPresent
```

## Структура образов

Образы публикуются в GitHub Container Registry:
- `ghcr.io/your-org/sausage-store/frontend:latest`
- `ghcr.io/your-org/sausage-store/backend:latest`  
- `ghcr.io/your-org/sausage-store/backend-report:latest`

Где `your-org` - это владелец GitHub репозитория.
