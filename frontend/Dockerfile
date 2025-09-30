# Multi-stage Dockerfile для Angular frontend

# Этап 1: Сборка Angular приложения
FROM node:16-alpine AS build

# Установка рабочей директории
WORKDIR /app

# Копирование package.json и package-lock.json
COPY package*.json ./

# Установка всех зависимостей (включая devDependencies для сборки)
RUN npm ci

# Установка Angular CLI глобально
RUN npm install -g @angular/cli@6.0.8

# Копирование исходного кода
COPY . .

# Сборка приложения для продакшена
RUN ng build --prod

# Этап 2: Nginx для раздачи статики
FROM nginx:alpine

# Копирование собранного приложения из первого этапа
COPY --from=build /app/dist/frontend /usr/share/nginx/html

# Копирование конфигурации nginx
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Открытие порта 80
EXPOSE 80

# Nginx запускается автоматически
