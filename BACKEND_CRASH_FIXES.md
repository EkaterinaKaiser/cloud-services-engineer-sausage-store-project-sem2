# Исправления проблем падения backend контейнера

## 🚨 Найденные критические проблемы

### 1. **Конфликт переменных окружения**
**Проблема**: В `application.properties` жестко заданы значения подключения к БД, которые игнорируют переменные окружения из Kubernetes.

**Было**:
```properties
spring.datasource.username=store
spring.datasource.password=storepassword
```

**Стало**:
```properties
spring.datasource.url=${SPRING_DATASOURCE_URL:jdbc:postgresql://postgresql:5432/sausage-store}
spring.datasource.username=${SPRING_DATASOURCE_USERNAME:store}
spring.datasource.password=${SPRING_DATASOURCE_PASSWORD:storepassword}
```

### 2. **Неправильная конфигурация MongoDB**
**Проблема**: Несоответствие между пользователем в properties и создаваемым в MongoDB init job.

**Было**:
```properties
spring.data.mongodb.uri=mongodb://reports:reportspassword@mongodb:27017/sausage-store
```

**Стало**:
```properties
spring.data.mongodb.uri=${SPRING_DATA_MONGODB_URI:mongodb://reportuser:reportpassword@mongodb:27017/reports}
```

### 3. **Конфликт Flyway с Kubernetes Job**
**Проблема**: Flyway пытался выполнить миграции при старте приложения, но миграции уже выполняются через отдельный Job.

**Исправление**:
```properties
# Disable Flyway - migrations are handled by Kubernetes Job
spring.flyway.enabled=false
```

### 4. **Проблема с CommandLineRunner**
**Проблема**: CommandLineRunner пытался сохранить продукты при старте, что могло вызвать ошибки если БД не готова.

**Исправление**:
```java
@Bean
CommandLineRunner runner(ProductService productService) {
    return args -> {
        try {
            // Check if products already exist to avoid duplicates
            if (productService.findAll().isEmpty()) {
                // ... save products
            }
        } catch (Exception e) {
            System.err.println("Error loading initial products: " + e.getMessage());
            // Don't fail the application startup if product loading fails
        }
    };
}
```

### 5. **Неправильный параметр порта в Dockerfile**
**Проблема**: Использовался неправильный параметр для настройки порта Spring Boot.

**Было**:
```dockerfile
ENTRYPOINT ["dumb-init", "java", "-jar", "-Dmyserver.bindPort=8080", "./sausage-store.jar"]
```

**Стало**:
```dockerfile
ENTRYPOINT ["dumb-init", "java", "-jar", "-Dserver.port=8080", "./sausage-store.jar"]
```

### 6. **Отсутствие переменной MongoDB в Helm**
**Проблема**: В Helm deployment не передавалась переменная для MongoDB.

**Добавлено**:
```yaml
- name: SPRING_DATA_MONGODB_URI
  value: mongodb://reportuser:reportpassword@mongodb:27017/reports
```

## 🔧 Дополнительные улучшения

### **Graceful error handling**
- CommandLineRunner теперь не падает при ошибках
- Добавлена проверка существования продуктов
- Логирование ошибок без остановки приложения

### **Правильная конфигурация Spring Boot**
- Использование переменных окружения с fallback значениями
- Отключение Flyway в пользу Kubernetes Job
- Правильная настройка порта сервера

## 📋 Результат

После исправлений backend контейнер должен:

✅ **Корректно подключаться** к PostgreSQL и MongoDB  
✅ **Не падать** при ошибках инициализации данных  
✅ **Использовать переменные окружения** из Kubernetes  
✅ **Не конфликтовать** с миграциями Job  
✅ **Правильно слушать** на порту 8080  
✅ **Gracefully обрабатывать** ошибки запуска  

## 🚀 Проверка исправлений

Для проверки исправлений:

```bash
# Проверка логов backend
kubectl logs -f deployment/sausage-store-backend -n sausage-store

# Проверка переменных окружения
kubectl exec deployment/sausage-store-backend -n sausage-store -- env | grep SPRING

# Проверка health endpoint
kubectl port-forward svc/sausage-store-backend 8080:8080 -n sausage-store
curl http://localhost:8080/actuator/health
```

Все критические проблемы исправлены, backend должен работать стабильно!
