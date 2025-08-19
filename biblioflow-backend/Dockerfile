# ===== Stage DEV =====
FROM node:22-alpine AS dev
WORKDIR /app

# Installer curl pour les healthchecks
RUN apk add --no-cache curl

# Copier les fichiers package
COPY package*.json ./

# Installer toutes les dépendances (dev + prod)
RUN npm ci

# Copier le code source
COPY . .

# Exposer le port 3000
EXPOSE 3000

# Commande de démarrage en mode développement
CMD ["npm", "run", "start:dev"]

# ===== Stage BUILD =====
FROM node:22-alpine AS builder
WORKDIR /app

# Copier les fichiers package
COPY package*.json ./

# Installer toutes les dépendances
RUN npm ci

# Copier le code source
COPY . .

# Build l'application
RUN npm run build

# ===== Stage PRODUCTION =====
FROM node:22-alpine AS prod

# Installer curl pour les healthchecks
RUN apk add --no-cache curl

# Créer un utilisateur non-root pour la sécurité
RUN addgroup -g 1001 -S nodejs
RUN adduser -S nestjs -u 1001

WORKDIR /app

# Copier les fichiers package
COPY package*.json ./

# Installer seulement les dépendances de production
RUN npm ci --only=production && npm cache clean --force

# Copier les fichiers buildés depuis le stage builder
COPY --from=builder /app/dist ./dist

# Changer le propriétaire des fichiers
RUN chown -R nestjs:nodejs /app
USER nestjs

# Variables d'environnement par défaut
ENV NODE_ENV=production
ENV PORT=3000

# Exposer le port
EXPOSE 3000

# Healthcheck
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:3000/health || exit 1

# Commande de démarrage
CMD ["node", "dist/main"]
