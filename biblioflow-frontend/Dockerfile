# ===== Stage DEV =====
FROM node:22-alpine AS dev
WORKDIR /app

# Installer Chrome/Chromium pour les tests (AJOUTÉ)
RUN apk add --no-cache \
    chromium \
    nss \
    freetype \
    freetype-dev \
    harfbuzz \
    ca-certificates \
    ttf-freefont

# Variables d'environnement pour Chrome (AJOUTÉ)
ENV CHROME_BIN=/usr/bin/chromium-browser
ENV CHROME_PATH=/usr/bin/chromium-browser

# Dépendances (VOTRE CODE ORIGINAL)
COPY package*.json ./
RUN npm ci

# Code (VOTRE CODE ORIGINAL)
COPY . .

# Servir l'app en dev (hot reload) (VOTRE CODE ORIGINAL)
ENV CHOKIDAR_USEPOLLING=1
EXPOSE 4200
CMD ["npx", "ng", "serve", "--host", "0.0.0.0", "--port", "4200"]

# ===== Stage PROD (build + runtime) ===== (VOTRE CODE ORIGINAL INCHANGÉ)
FROM node:22-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .

# Build Angular
RUN npx ng build --configuration=production --output-path=/app/dist

FROM nginx:alpine AS prod
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copier depuis le bon dossier (browser/ pour Angular 17+)
COPY --from=builder /app/dist/browser/ /usr/share/nginx/html/

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
