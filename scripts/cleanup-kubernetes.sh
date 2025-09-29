#!/bin/bash

# Скрипт для очистки ресурсов Sausage Store в Kubernetes
# Использование: ./cleanup-kubernetes.sh [namespace]

set -e

NAMESPACE=${1:-default}

echo "🧹 Очистка ресурсов Sausage Store в namespace: $NAMESPACE"

# Проверяем подключение к кластеру
if ! kubectl cluster-info >/dev/null 2>&1; then
    echo "❌ Ошибка: Не удается подключиться к Kubernetes кластеру"
    echo "Убедитесь, что kubectl настроен и кластер доступен"
    exit 1
fi

echo "📋 Текущие ресурсы в namespace $NAMESPACE:"
kubectl get all -n $NAMESPACE | grep sausage || echo "Ресурсы Sausage Store не найдены"

echo ""
echo "🗑️  Удаление Helm релиза..."
helm uninstall sausage-store -n $NAMESPACE || echo "Релиз sausage-store не найден"

echo ""
echo "🗑️  Удаление ресурсов по лейблам..."
kubectl delete deployment,service,ingress,configmap,secret,pvc,hpa,vpa,job \
  --selector=app.kubernetes.io/part-of=sausage-store \
  -n $NAMESPACE --ignore-not-found=true || true

kubectl delete deployment,service,ingress,configmap,secret,pvc,hpa,vpa,job \
  --selector=app=sausage-store \
  -n $NAMESPACE --ignore-not-found=true || true

echo ""
echo "🗑️  Удаление ресурсов по именам..."
kubectl delete deployment postgresql mongodb -n $NAMESPACE --ignore-not-found=true || true
kubectl delete service postgresql-service mongodb-service -n $NAMESPACE --ignore-not-found=true || true
kubectl delete job mongodb-init-job -n $NAMESPACE --ignore-not-found=true || true
kubectl delete pvc postgresql-pvc -n $NAMESPACE --ignore-not-found=true || true

echo ""
echo "⏳ Ожидание завершения удаления..."
sleep 10

echo ""
echo "🔍 Проверка оставшихся ресурсов:"
kubectl get all -n $NAMESPACE | grep -E "(sausage|postgres|mongo)" || echo "Все ресурсы Sausage Store удалены"

echo ""
echo "✅ Очистка завершена!"
echo ""
echo "📊 Общий статус namespace $NAMESPACE:"
kubectl get all -n $NAMESPACE
