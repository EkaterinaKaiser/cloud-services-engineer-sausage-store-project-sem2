# Ограничения ресурсов для namespace r-devops-magistracy-project-2sem-907324971

## Лимиты кластера
- **CPU (request)**: 2 ядра
- **Memory (request)**: 1000Mi (≈1GB)
- **CPU (limit)**: 3 ядра
- **Memory (limit)**: 2500Mi (≈2.5GB)
- **Количество Pods**: 10
- **Количество Services**: 5
- **Количество Secrets**: 10
- **Количество ConfigMaps**: 10
- **Количество PersistentVolumeClaims**: 4
- **Объём хранилища**: 5Gi (≈5GB)

## Распределение ресурсов

### Frontend (Nginx)
- **CPU request**: 50m
- **CPU limit**: 200m
- **Memory request**: 50Mi
- **Memory limit**: 100Mi
- **Replicas**: 1

### Backend (Spring Boot)
- **CPU request**: 200m
- **CPU limit**: 500m
- **Memory request**: 200Mi
- **Memory limit**: 400Mi
- **Replicas**: 1

### Backend-report (Go)
- **CPU request**: 100m
- **CPU limit**: 300m
- **Memory request**: 100Mi
- **Memory limit**: 200Mi
- **Replicas**: 1 (HPA: 1-3)

### PostgreSQL
- **CPU request**: 200m
- **CPU limit**: 500m
- **Memory request**: 200Mi
- **Memory limit**: 400Mi
- **Storage**: 2Gi
- **Replicas**: 1

### MongoDB
- **CPU request**: 100m
- **CPU limit**: 300m
- **Memory request**: 100Mi
- **Memory limit**: 300Mi
- **Replicas**: 1

## Итого используемых ресурсов

### CPU
- **Request**: 650m (0.65 ядра) из 2000m (2 ядра) = 32.5%
- **Limit**: 1500m (1.5 ядра) из 3000m (3 ядра) = 50%

### Memory
- **Request**: 650Mi из 1000Mi = 65%
- **Limit**: 1000Mi из 2500Mi = 40%

### Storage
- **PostgreSQL**: 2Gi из 5Gi = 40%


## Оптимизации

1. **HPA для backend-report**: Автомасштабирование от 1 до 3 реплик
2. **Минимальные ресурсы**: Все сервисы используют минимально необходимые ресурсы
3. **Эффективное хранение**: PostgreSQL использует только 2Gi из доступных 5Gi
4. **Оптимизированные образы**: Multi-stage Dockerfiles для уменьшения размера
