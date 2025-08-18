# ===== Stage DEV =====
FROM node:22-alpine AS dev
WORKDIR /app

# Dépendances
COPY package*.json ./
RUN npm ci

# Code
COPY . .

# Servir l'app en dev (hot reload)
ENV CHOKIDAR_USEPOLLING=1
EXPOSE 4200
CMD ["npx", "ng", "serve", "--host", "0.0.0.0", "--port", "4200"]

# ===== Stage PROD (build + runtime) =====
FROM node:22-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
# On force le répertoire de sortie pour ne pas dépendre du nom de projet
RUN npx ng build --configuration=production --output-path=/app/dist

FROM nginx:alpine AS prod
# Copie uniquement les fichiers statiques buildés
COPY --from=builder /app/dist/ /usr/share/nginx/html/
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
