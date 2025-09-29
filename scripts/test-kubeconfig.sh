#!/bin/bash

# Скрипт для тестирования kubeconfig перед добавлением в GitHub Secrets
# Использование: ./test-kubeconfig.sh [path-to-kubeconfig]

set -e

KUBECONFIG_FILE=${1:-~/.kube/config}

echo "🔍 Тестирование kubeconfig: $KUBECONFIG_FILE"
echo ""

# Проверка существования файла
if [ ! -f "$KUBECONFIG_FILE" ]; then
    echo "❌ Файл kubeconfig не найден: $KUBECONFIG_FILE"
    exit 1
fi

echo "📁 Информация о файле:"
echo "Размер: $(wc -c < "$KUBECONFIG_FILE") байт"
echo "Строк: $(wc -l < "$KUBECONFIG_FILE")"
echo ""

# Проверка синтаксиса YAML
echo "🔍 Проверка синтаксиса YAML..."
if kubectl --kubeconfig="$KUBECONFIG_FILE" get nodes --dry-run=client >/dev/null 2>&1; then
    echo "✅ Синтаксис YAML корректен"
else
    echo "❌ Ошибка синтаксиса YAML"
    kubectl --kubeconfig="$KUBECONFIG_FILE" get nodes --dry-run=client 2>&1 || true
fi

# Проверка подключения к кластеру
echo ""
echo "🌐 Проверка подключения к кластеру..."
if kubectl --kubeconfig="$KUBECONFIG_FILE" cluster-info >/dev/null 2>&1; then
    echo "✅ Подключение к кластеру успешно"
    kubectl --kubeconfig="$KUBECONFIG_FILE" cluster-info
else
    echo "❌ Не удается подключиться к кластеру"
    kubectl --kubeconfig="$KUBECONFIG_FILE" cluster-info 2>&1 || true
fi

# Проверка прав доступа
echo ""
echo "🔐 Проверка прав доступа..."
if kubectl --kubeconfig="$KUBECONFIG_FILE" get namespaces >/dev/null 2>&1; then
    echo "✅ Права доступа достаточны"
    echo "Доступные namespace:"
    kubectl --kubeconfig="$KUBECONFIG_FILE" get namespaces --no-headers | awk '{print $1}'
else
    echo "❌ Недостаточно прав доступа"
    kubectl --kubeconfig="$KUBECONFIG_FILE" get namespaces 2>&1 || true
fi

# Проверка содержимого
echo ""
echo "📋 Содержимое kubeconfig:"
echo "Первые 10 строк:"
head -10 "$KUBECONFIG_FILE"
echo ""
echo "Последние 10 строк:"
tail -10 "$KUBECONFIG_FILE"

# Проверка на base64
echo ""
echo "🔍 Проверка формата:"
if echo "$(cat "$KUBECONFIG_FILE")" | base64 -d >/dev/null 2>&1; then
    echo "⚠️  Файл может быть в base64 формате"
    echo "Для GitHub Actions используйте содержимое как есть (plain text)"
else
    echo "✅ Файл в plain text формате"
fi

echo ""
echo "📝 Рекомендации для GitHub Secrets:"
echo "1. Скопируйте содержимое файла полностью"
echo "2. Вставьте в GitHub Secret KUBE_CONFIG как есть"
echo "3. Не кодируйте в base64, если файл уже в plain text"
echo "4. Убедитесь, что все строки скопированы (включая certificate-authority-data)"
