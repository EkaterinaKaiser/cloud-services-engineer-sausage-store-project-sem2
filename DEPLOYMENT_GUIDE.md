# 🚀 Руководство по деплою Sausage Store

## 📋 Обзор

Этот документ содержит пошаговые инструкции для развертывания приложения "Сосисочная" в Kubernetes кластере на Yandex Cloud с использованием Helm и автоматического деплоя через GitHub Actions.

## 🏗️ Архитектура приложения

- **Frontend** - Angular приложение с Nginx
- **Backend** - Java Spring Boot приложение
- **Backend-report** - Go приложение для генерации отчетов
- **PostgreSQL** - основная база данных
- **MongoDB** - база данных для отчетов

## 📝 Предварительные требования

### 1. **Kubernetes кластер**
- Рабочий кластер Kubernetes на Yandex Cloud
- Доступ к кластеру через `kubectl`
- Ingress Controller (Nginx) установлен

### 2. **Docker Hub аккаунт**
- Зарегистрированный аккаунт на Docker Hub
- Права на создание репозиториев

### 3. **Nexus Repository Manager**
- Доступ к Nexus (например, `https://nexus.cloud-services-engineer.education-services.ru`)
- Права на создание Helm репозиториев

### 4. **GitHub репозиторий**
- Код проекта загружен в GitHub
- Права на настройку Secrets и Variables

## 🔧 Шаг 1: Настройка Docker Hub

### 1.1 Создайте репозитории в Docker Hub

Войдите в Docker Hub и создайте следующие репозитории:
- `your-username/sausage-frontend`
- `your-username/sausage-backend`
- `your-username/sausage-backend-report`

### 1.2 Получите токен доступа

1. Перейдите в Account Settings → Security
2. Создайте новый Access Token
3. Сохраните username и token

## 🔧 Шаг 2: Настройка Nexus

### 2.1 Создайте Helm репозиторий

1. Войдите в Nexus Repository Manager
2. Перейдите в Administration → Repositories
3. Нажмите "Create repository"
4. Выберите "Helm (hosted)"
5. Настройте параметры:
   - **Name**: `my-helm-repo` (или любое другое имя)
   - **Online**: ✅ включено
   - **Deployment policy**: Allow redeploy
6. Сохраните репозиторий

### 2.2 Получите URL репозитория

URL будет выглядеть так:
```
https://nexus.cloud-services-engineer.education-services.ru/repository/my-helm-repo
```

### 2.3 Создайте пользователя для доступа

1. Перейдите в Administration → Security → Users
2. Создайте нового пользователя
3. Назначьте роли для работы с Helm репозиторием
4. Сохраните username и password

## 🔧 Шаг 3: Настройка Kubernetes

### 3.1 Получите kubeconfig

```bash
# Получите kubeconfig из кластера
kubectl config view --raw > kubeconfig.yaml

# Проверьте подключение
kubectl get nodes
```

### 3.2 Создайте namespace (опционально)

```bash
kubectl create namespace sausage-store
```

## 🔧 Шаг 4: Настройка GitHub Secrets

### 4.1 Перейдите в настройки репозитория

1. Откройте ваш GitHub репозиторий
2. Перейдите в Settings → Secrets and variables → Actions

### 4.2 Добавьте следующие секреты

#### **Обязательные секреты:**

| Secret Name | Описание | Пример значения |
|-------------|----------|-----------------|
| `KUBE_CONFIG` | Содержимое kubeconfig файла | `apiVersion: v1\nclusters:...` |
| `DOCKER_USER` | Username Docker Hub | `your-dockerhub-username` |
| `DOCKER_PASSWORD` | Password/Token Docker Hub | `your-dockerhub-token` |
| `NEXUS_HELM_REPO` | URL Helm репозитория | `https://nexus.cloud-services-engineer.education-services.ru/repository/my-helm-repo` |
| `NEXUS_HELM_REPO_USER` | Username для Nexus | `your-nexus-username` |
| `NEXUS_HELM_REPO_PASSWORD` | Password для Nexus | `your-nexus-password` |

#### **Дополнительные секреты (опционально):**

| Secret Name | Описание | Значение по умолчанию |
|-------------|----------|----------------------|
| `POSTGRES_PASSWORD` | Пароль PostgreSQL | `storepassword` |
| `MONGO_ROOT_PASSWORD` | Root пароль MongoDB | `rootpassword` |

### 4.3 Добавьте переменные окружения

Перейдите в Settings → Secrets and variables → Actions → Variables:

| Variable Name | Описание | Пример значения |
|---------------|----------|-----------------|
| `SAUSAGE_STORE_NAMESPACE` | Namespace для деплоя | `sausage-store` |
| `INGRESS_HOST` | Домен для Ingress | `your-hostname.students-projects.ru` |

## 🔧 Шаг 5: Настройка Ingress

### 5.1 Получите внешний IP

```bash
# Проверьте, что Ingress Controller работает
kubectl get svc -n ingress-nginx

# Получите внешний IP
kubectl get ingress -A
```

### 5.2 Настройте DNS

Настройте DNS запись для вашего домена, указывающую на внешний IP Ingress Controller.

## 🚀 Шаг 6: Запуск деплоя

### 6.1 Автоматический деплой

1. Сделайте commit и push в ветку `main`:
```bash
git add .
git commit -m "Deploy sausage store application"
git push origin main
```

2. GitHub Actions автоматически:
   - Соберет Docker образы
   - Загрузит их в Docker Hub
   - Упакует Helm чарт
   - Загрузит чарт в Nexus
   - Развернет приложение в Kubernetes

### 6.2 Мониторинг деплоя

1. Перейдите в Actions в GitHub
2. Откройте последний workflow
3. Следите за выполнением каждого шага

## 🔍 Шаг 7: Проверка деплоя

### 7.1 Проверьте статус подов

```bash
kubectl get pods -n sausage-store
```

Ожидаемый результат:
```
NAME                                    READY   STATUS    RESTARTS   AGE
sausage-store-backend-xxx               1/1     Running   0          2m
sausage-store-backend-report-xxx        1/1     Running   0          2m
sausage-store-frontend-xxx              1/1     Running   0          2m
postgresql-xxx                          1/1     Running   0          3m
mongodb-xxx                             1/1     Running   0          3m
```

### 7.2 Проверьте сервисы

```bash
kubectl get svc -n sausage-store
```

### 7.3 Проверьте Ingress

```bash
kubectl get ingress -n sausage-store
```

### 7.4 Проверьте логи

```bash
# Логи backend
kubectl logs -f deployment/sausage-store-backend -n sausage-store

# Логи frontend
kubectl logs -f deployment/sausage-store-frontend -n sausage-store

# Логи backend-report
kubectl logs -f deployment/sausage-store-backend-report -n sausage-store
```

## 🌐 Шаг 8: Тестирование приложения

### 8.1 Проверьте доступность

1. Откройте браузер
2. Перейдите по адресу: `http://your-hostname.students-projects.ru`
3. Убедитесь, что frontend загружается

### 8.2 Проверьте API

```bash
# Health check backend
curl http://your-hostname.students-projects.ru/api/actuator/health

# Health check backend-report
curl http://your-hostname.students-projects.ru:8080/health
```

### 8.3 Проверьте базы данных

```bash
# Подключение к PostgreSQL
kubectl exec -it deployment/postgresql -n sausage-store -- psql -U store -d sausage-store -c "SELECT * FROM product LIMIT 5;"

# Подключение к MongoDB
kubectl exec -it deployment/mongodb -n sausage-store -- mongo --eval "db.stats()"
```

## 🔧 Шаг 9: Ручной деплой (альтернатива)

Если автоматический деплой не работает, можно развернуть вручную:

### 9.1 Соберите образы локально

```bash
# Backend
cd backend
docker build -t your-username/sausage-backend:latest .
docker push your-username/sausage-backend:latest

# Frontend
cd ../frontend
docker build -t your-username/sausage-frontend:latest .
docker push your-username/sausage-frontend:latest

# Backend-report
cd ../backend-report
docker build -t your-username/sausage-backend-report:latest .
docker push your-username/sausage-backend-report:latest
```

### 9.2 Разверните Helm чарт

```bash
cd sausage-store-chart

# Обновите зависимости
helm dependency update

# Установите чарт
helm install sausage-store . \
  --namespace sausage-store \
  --create-namespace \
  --set frontend.image=your-username/sausage-frontend:latest \
  --set backend.image=your-username/sausage-backend:latest \
  --set backend-report.image=your-username/sausage-backend-report:latest \
  --set frontend.ingress.host=your-hostname.students-projects.ru
```

## 🛠️ Шаг 10: Устранение неполадок

### 10.1 Проблемы с образами

```bash
# Проверьте, что образы загружены
docker pull your-username/sausage-backend:latest
docker pull your-username/sausage-frontend:latest
docker pull your-username/sausage-backend-report:latest
```

### 10.2 Проблемы с подключением к БД

```bash
# Проверьте логи init containers
kubectl logs deployment/sausage-store-backend -n sausage-store -c wait-for-db

# Проверьте статус миграций
kubectl get jobs -n sausage-store
kubectl logs job/sausage-store-infra-migrations -n sausage-store
```

### 10.3 Проблемы с Ingress

```bash
# Проверьте Ingress Controller
kubectl get pods -n ingress-nginx

# Проверьте конфигурацию Ingress
kubectl describe ingress sausage-store-frontend -n sausage-store
```

### 10.4 Проблемы с ресурсами

```bash
# Проверьте использование ресурсов
kubectl top pods -n sausage-store

# Проверьте события
kubectl get events -n sausage-store --sort-by='.lastTimestamp'
```

## 📊 Шаг 11: Мониторинг и масштабирование

### 11.1 Проверьте VPA (Vertical Pod Autoscaler)

```bash
kubectl get vpa -n sausage-store
kubectl describe vpa sausage-store-backend-vpa -n sausage-store
```

### 11.2 Проверьте HPA (Horizontal Pod Autoscaler)

```bash
kubectl get hpa -n sausage-store
kubectl describe hpa sausage-store-backend-report-hpa -n sausage-store
```

### 11.3 Масштабирование вручную

```bash
# Масштабирование backend
kubectl scale deployment sausage-store-backend --replicas=3 -n sausage-store

# Масштабирование frontend
kubectl scale deployment sausage-store-frontend --replicas=2 -n sausage-store
```

## 🎉 Готово!

После выполнения всех шагов ваше приложение "Сосисочная" будет развернуто в Kubernetes кластере и доступно по адресу `http://your-hostname.students-projects.ru`.

### Полезные команды для управления:

```bash
# Обновление приложения
helm upgrade sausage-store . -n sausage-store

# Удаление приложения
helm uninstall sausage-store -n sausage-store

# Просмотр статуса
helm status sausage-store -n sausage-store

# Просмотр логов
kubectl logs -f deployment/sausage-store-backend -n sausage-store
```

## 📞 Поддержка

Если возникли проблемы:
1. Проверьте логи в GitHub Actions
2. Проверьте логи подов в Kubernetes
3. Убедитесь, что все секреты настроены правильно
4. Проверьте доступность внешних сервисов (Docker Hub, Nexus)
