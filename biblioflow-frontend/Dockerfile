# ===== Stage DEV =====
FROM node:22-alpine AS dev
WORKDIR /usr/src/app

# Installer les dépendances pour Chrome (pour les tests)
RUN apk add --no-cache \
    chromium \
    nss \
    freetype \
    freetype-dev \
    harfbuzz \
    ca-certificates \
    ttf-freefont

ENV CHROME_BIN=/usr/bin/chromium-browser
ENV CHROME_PATH=/usr/bin/chromium-browser

# Copier package.json et package-lock.json
COPY package*.json ./

# Installer les dépendances
RUN npm ci

# Copier le code source
COPY . .

# Variables d'environnement pour le polling (nécessaire dans Docker)
ENV CHOKIDAR_USEPOLLING=1

# Exposer le port
EXPOSE 4200

# Commande pour Angular CLI en mode dev
CMD ["npx", "ng", "serve", "--host", "0.0.0.0", "--port", "4200", "--poll", "2000"]

# ===== Stage BUILD =====
FROM node:22-alpine AS builder
WORKDIR /app

# Copier package.json et installer les dépendances
COPY package*.json ./
RUN npm ci

# Copier le code source
COPY . .

# Build Angular en mode production
RUN npx ng build --configuration=production

# ===== Stage PRODUCTION =====
FROM nginx:alpine AS prod

# Copier la configuration nginx personnalisée
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copier les fichiers buildés
# Note: Avec Angular 17+, les fichiers sont dans dist/browser/
COPY --from=builder /app/dist/biblioflow-frontend/browser/ /usr/share/nginx/html/

# Exposer le port 80
EXPOSE 80

# Démarrer nginx
CMD ["nginx", "-g", "daemon off;"]
