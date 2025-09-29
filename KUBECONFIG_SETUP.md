# Настройка KUBE_CONFIG для GitHub Actions

## Проблема
Ошибка `base64: invalid input` при попытке декодирования kubeconfig в GitHub Actions.

## Причины
1. Kubeconfig уже в plain text формате (не закодирован в base64)
2. Kubeconfig закодирован в base64, но GitHub Actions пытается декодировать его дважды
3. Неправильный формат kubeconfig

## Решения

### Вариант 1: Plain Text (Рекомендуется)
Если ваш kubeconfig уже в текстовом формате:

1. Скопируйте содержимое файла `~/.kube/config`
2. Вставьте его в GitHub Secret `KUBE_CONFIG` как есть (без кодирования)

**Важно:** Убедитесь, что kubeconfig содержит полные данные, включая:
- `apiVersion: v1`
- `kind: Config`
- `clusters` с `certificate-authority-data`
- `contexts` с правильным контекстом
- `users` с токеном или сертификатом

### Вариант 2: Base64 кодирование
Если нужно закодировать kubeconfig в base64:

```bash
# Кодирование в base64
cat ~/.kube/config | base64 -w 0

# Или для macOS
cat ~/.kube/config | base64 -b 0
```

Затем вставьте результат в GitHub Secret `KUBE_CONFIG`.

### Вариант 3: Проверка целостности kubeconfig
Перед добавлением в GitHub Secret проверьте kubeconfig:

```bash
# Проверка синтаксиса
kubectl --kubeconfig=~/.kube/config get nodes --dry-run=client

# Проверка размера файла
wc -c ~/.kube/config

# Проверка содержимого
head -20 ~/.kube/config
tail -20 ~/.kube/config
```

### Вариант 3: Проверка формата
Чтобы проверить, в каком формате ваш kubeconfig:

```bash
# Проверка, является ли содержимое base64
echo "YOUR_KUBECONFIG_CONTENT" | base64 -d >/dev/null 2>&1 && echo "Base64" || echo "Plain text"

# Декодирование base64 (если нужно)
echo "YOUR_KUBECONFIG_CONTENT" | base64 -d
```

## Автоматическое определение формата

GitHub Actions теперь автоматически определяет формат kubeconfig и пробует:

1. **Plain text** - использует как есть
2. **Base64** - декодирует один раз
3. **Двойное base64** - декодирует дважды

## Структура kubeconfig

Правильный kubeconfig должен содержать:

```yaml
apiVersion: v1
kind: Config
clusters:
- cluster:
    server: https://your-cluster-url
    certificate-authority-data: LS0tLS1CRUdJTi...
  name: your-cluster
contexts:
- context:
    cluster: your-cluster
    user: your-user
  name: your-context
current-context: your-context
users:
- name: your-user
  user:
    token: your-token
```

## Проверка подключения

После настройки секрета, GitHub Actions проверит подключение командой:

```bash
kubectl cluster-info
```

## Отладка

Если подключение не удается, в логах будет показано:
- Какой способ декодирования использовался
- Первые 100 символов kubeconfig
- Результат команды `kubectl cluster-info`

## Рекомендации

1. **Используйте plain text** - проще и надежнее
2. **Проверьте права доступа** - убедитесь, что токен имеет права на деплой
3. **Обновите токен** - если токен истек
4. **Проверьте URL кластера** - убедитесь, что кластер доступен
