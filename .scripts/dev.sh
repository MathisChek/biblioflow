#!/bin/bash

# Scripts utilitaires pour le développement BiblioFlow

case "$1" in
  "start")
    echo "🚀 Démarrage de l'environnement de développement..."
    docker-compose up backend-dev frontend-dev postgres
    ;;
  "stop")
    echo "⏹️ Arrêt de l'environnement de développement..."
    docker-compose stop
    ;;
  "rebuild")
    echo "🔨 Reconstruction des images de développement..."
    docker-compose build --no-cache backend-dev frontend-dev
    ;;
  "logs")
    if [ -n "$2" ]; then
      docker-compose logs -f $2
    else
      docker-compose logs -f backend-dev frontend-dev
    fi
    ;;
  "clean")
    echo "🧹 Nettoyage complet..."
    docker-compose down -v
    docker system prune -f
    ;;
  "test-api")
    echo "🧪 Test de l'API..."
    curl http://localhost:3000/health
    curl http://localhost:3000/books
    ;;
  *)
    echo "Usage: $0 {start|stop|rebuild|logs|clean|test-api}"
    echo ""
    echo "Commandes disponibles:"
    echo "  start     - Démarre l'environnement de dev"
    echo "  stop      - Arrête l'environnement"
    echo "  rebuild   - Reconstruit les images"
    echo "  logs      - Affiche les logs (optionnel: service name)"
    echo "  clean     - Nettoyage complet"
    echo "  test-api  - Teste l'API rapidement"
    ;;
esac
