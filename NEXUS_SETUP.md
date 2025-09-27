# Инструкция по настройке Nexus для Helm репозитория

## Что можно сделать автоматически ✅

1. **Обновлен GitHub Actions workflow** для работы с Nexus
2. **Настроена упаковка Helm чарта** и загрузка в Nexus
3. **Настроен деплой из Nexus** в Kubernetes кластер

## Что нужно сделать вручную 🔧

### 1. Создание Helm репозитория в Nexus

#### Шаги:

1. **Войдите в Nexus** по адресу: `https://nexus.cloud-services-engineer.education-services.ru`

2. **Перейдите в раздел "Repositories"**:
   - В левом меню выберите "Repositories"
   - Нажмите "Create repository"

3. **Выберите тип репозитория**:
   - Выберите "Helm (hosted)"

4. **Настройте репозиторий**:
   ```
   Name: your-helm-repo
   Version policy: Release
   Write policy: Allow redeploy
   Blob store: default
   ```

5. **Сохраните репозиторий**

### 2. Получение URL репозитория

После создания репозитория URL будет иметь вид:
```
https://nexus.cloud-services-engineer.education-services.ru/repository/your-helm-repo
```

### 3. Настройка GitHub Secrets

Добавьте следующие секреты в GitHub (Settings → Secrets and variables → Actions):

#### Обязательные секреты:
- `NEXUS_HELM_REPO` = `https://nexus.cloud-services-engineer.education-services.ru/repository/your-helm-repo`
- `NEXUS_HELM_REPO_USER` = ваш username для Nexus
- `NEXUS_HELM_REPO_PASSWORD` = ваш password для Nexus

#### Дополнительные секреты:
- `DOCKER_USER` = ваш Docker Hub username
- `DOCKER_PASSWORD` = ваш Docker Hub password
- `KUBE_CONFIG` = содержимое kubeconfig файла
- `SAUSAGE_STORE_NAMESPACE` = `sausage-store`
- `INGRESS_HOST` = ваш домен (например: `your-hostname.students-projects.ru`)

### 4. Проверка настройки

После настройки всех секретов:

1. **Запушьте код в main ветку**
2. **Проверьте выполнение workflow** в разделе Actions
3. **Убедитесь, что Helm чарт загрузился в Nexus**:
   - Перейдите в Nexus → Repositories → your-helm-repo
   - Должен появиться файл `sausage-store-YYYYMMDDHHMMSS.tgz`

## Как это работает

### Workflow процесс:

1. **Сборка образов** → Docker Hub
2. **Упаковка Helm чарта** → локально
3. **Загрузка в Nexus** → `helm package` + `curl upload`
4. **Добавление Nexus репозитория** → `helm repo add nexus`
5. **Деплой из Nexus** → `helm upgrade --install nexus/sausage-store`

### Команды, которые выполняются автоматически:

```bash
# Упаковка чарта
helm package . --destination ./packages

# Загрузка в Nexus
curl -u $NEXUS_USER:$NEXUS_PASSWORD \
  --upload-file ./packages/sausage-store-*.tgz \
  $NEXUS_HELM_REPO/sausage-store-$(date +%Y%m%d%H%M%S).tgz

# Добавление репозитория
helm repo add nexus $NEXUS_HELM_REPO \
  --username $NEXUS_USER --password $NEXUS_PASSWORD
helm repo update

# Деплой из Nexus
helm upgrade --install sausage-store nexus/sausage-store \
  --namespace $NAMESPACE --create-namespace
```

## Troubleshooting

### Проблема: Ошибка аутентификации в Nexus
**Решение**: Проверьте правильность `NEXUS_HELM_REPO_USER` и `NEXUS_HELM_REPO_PASSWORD`

### Проблема: Ошибка загрузки чарта
**Решение**: Убедитесь, что URL `NEXUS_HELM_REPO` правильный и репозиторий существует

### Проблема: Ошибка деплоя из Nexus
**Решение**: Проверьте, что чарт успешно загрузился в Nexus и доступен

### Проблема: Ошибка kubeconfig
**Решение**: Убедитесь, что `KUBE_CONFIG` содержит актуальный kubeconfig файл

## Дополнительные настройки

### Настройка прав доступа в Nexus

1. **Создайте пользователя** для CI/CD (если нужно)
2. **Настройте права** на репозиторий:
   - nx-repository-view-helm-your-helm-repo-browse
   - nx-repository-view-helm-your-helm-repo-read
   - nx-repository-view-helm-your-helm-repo-edit

### Мониторинг репозитория

- **Просмотр загруженных чартов**: Nexus → Repositories → your-helm-repo
- **Логи загрузки**: Nexus → System → Logging
- **Статистика использования**: Nexus → System → Health Check

## Результат

После выполнения всех шагов у вас будет:

✅ **Helm репозиторий в Nexus** с вашими чартами  
✅ **Автоматическая загрузка** чартов при каждом пуше  
✅ **Автоматический деплой** из Nexus в Kubernetes  
✅ **Полный CI/CD pipeline** с использованием Nexus как артефакт-репозитория
