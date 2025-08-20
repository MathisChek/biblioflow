pipeline {
    agent any

    tools {
        nodejs "Node_24"
    }

    environment {
        COMPOSE_PROJECT_NAME = "biblioflow-ci"
        DOCKER_BUILDKIT = "1"
    }

    stages {
        stage('Checkout') {
            steps {
                dir('/workspace/biblioflow') {
                    sh 'pwd && ls -la'
                    echo 'Repository local monté'
                }
            }
        }

        stage('Preflight Check') {
            steps {
                dir('/workspace/biblioflow') {
                    script {
                        // Vérifier que Docker fonctionne
                        sh 'docker --version'
                        sh 'docker-compose --version'

                        // Vérifier les fichiers nécessaires
                        sh 'ls -la docker-compose.yml'

                        if (fileExists('compose.ci.yml')) {
                            echo 'Override CI présent'
                        } else {
                            echo 'Pas d\'override, on continue'
                        }
                    }
                }
            }
        }

        stage('Prepare Environment') {
            steps {
                dir('/workspace/biblioflow') {
                    script {
                        // Copier .env pour CI
                        sh 'cp .env .env.ci'

                        // Modifier les variables pour CI
                        sh '''
                            sed -i 's/biblioflow_dev/biblioflow_ci/g' .env.ci
                            echo "NODE_ENV=ci" >> .env.ci
                        '''
                    }
                }
            }
        }

        stage('Build Frontend') {
            steps {
                dir('/workspace/biblioflow') {
                    script {
                        if (fileExists('compose.ci.yml')) {
                            sh 'docker-compose -f docker-compose.yml -f compose.ci.yml build frontend-dev'
                        } else {
                            sh 'docker-compose build frontend-dev'
                        }
                    }
                }
            }
        }

        stage('Run Tests Frontend') {
            steps {
                dir('/workspace/biblioflow') {
                    script {
                        if (fileExists('compose.ci.yml')) {
                            sh 'docker-compose -f docker-compose.yml -f compose.ci.yml run --rm frontend-dev npm run test:ci'
                        } else {
                            echo 'Tests frontend à configurer'
                        }
                    }
                }
            }
        }

        stage('Build Backend') {
            steps {
                dir('/workspace/biblioflow') {
                    script {
                        if (fileExists('compose.ci.yml')) {
                            sh 'docker-compose -f docker-compose.yml -f compose.ci.yml build backend-dev'
                        } else {
                            sh 'docker-compose build backend-dev'
                        }
                    }
                }
            }
        }

        stage('Deploy for Testing') {
            steps {
                dir('/workspace/biblioflow') {
                    script {
                        // Arrêter les services existants
                        sh 'docker-compose down || true'

                        // Démarrer avec la config CI
                        if (fileExists('compose.ci.yml')) {
                            sh 'docker-compose -f docker-compose.yml -f compose.ci.yml up -d postgres'
                            sh 'sleep 30'  // Attendre que postgres soit prêt
                            sh 'docker-compose -f docker-compose.yml -f compose.ci.yml up -d backend-dev frontend-dev'
                        } else {
                            sh 'docker-compose up -d postgres backend-dev frontend-dev'
                        }
                    }
                }
            }
        }

        stage('Health Check') {
            steps {
                dir('/workspace/biblioflow') {
                    script {
                        // Attendre que les services soient prêts
                        sh 'sleep 60'

                        // Tester l'API
                        sh 'curl -f http://localhost:3000/health || exit 1'

                        // Tester les routes books
                        sh 'curl -f http://localhost:3000/books || exit 1'

                        echo 'Health checks passed!'
                    }
                }
            }
        }
    }

    post {
        success {
            echo 'Pipeline succeeded!'
            echo '==================================='
            echo 'Application déployée et disponible :'
            echo '- Frontend: http://localhost:4200'
            echo '- Backend: http://localhost:3000'
            echo '- API Health: http://localhost:3000/health'
            echo '- API Books: http://localhost:3000/books'
            echo '==================================='
            echo 'Pour arrêter : docker-compose down'
            // Ne pas faire de nettoyage automatique
        }
        failure {
            echo 'Pipeline failed!'
            dir('/workspace/biblioflow') {
                sh 'docker-compose down || true'  // Nettoyer seulement si échec
                sh 'docker system prune -f || true'
            }
        }
    }
}
