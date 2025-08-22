pipeline {
    agent any
    options {
        disableConcurrentBuilds()
    }
    tools {
        nodejs "Node_24"
    }
    environment {
        DOCKER_COMPOSE_DEPLOY_BASE = "/workspace/biblioflow/compose.yml"
        DOCKER_COMPOSE_DEPLOY_OVR = "/workspace/biblioflow/compose.ci.yml"
        COMPOSE_PROJECT_NAME_DEPLOY = "biblioflow"
        CI = "true"
    }
    stages {
        stage('Checkout') {
            steps {
                dir("${WORKSPACE}") {
                    sh 'pwd && ls -la'
                    echo 'Files already mounted from volume'
                }
            }
        }
        stage('Preflight') {
            steps {
                sh '''
                    test -f ${DOCKER_COMPOSE_DEPLOY_BASE} && echo "OK: compose.yml found" || (echo "ERROR: compose.yml missing" && exit 1)
                    [ -f ${DOCKER_COMPOSE_DEPLOY_OVR} ] && echo "compose.ci.yml present (will be used)" || echo "compose.ci.yml not present (will be skipped)"
                '''
            }
        }
        stage('Prepare Environment') {
            steps {
                sh '''
                    cat > "/workspace/biblioflow/.env" << EOF
# JWT
JWT_SECRET=dev_jwt_secret_not_secure_for_dev_only

# Application
PORT=3000
NODE_ENV=development

# Variables pour Docker Compose
DB_NAME=biblioflow_dev
POSTGRES_USER: biblioflow_user
POSTGRES_PASSWORD: ci_password

# Variables pour l'application NestJS
DATABASE_HOST=postgres
DATABASE_PORT=5432
DATABASE_USER=postgres
DATABASE_PASSWORD=secure_password_123
DATABASE_NAME=biblioflow_dev
DATABASE_SSL=false
DATABASE_SYNCHRONIZE=true
DATABASE_LOGGING=true
EOF
                    chmod 600 "/workspace/biblioflow/.env"
                    echo "✓ .env created for CI"
                '''
            }
        }
        stage('Assemble deploy compose files') {
            steps {
                dir("/workspace/biblioflow") {
                    sh '''
                        DEPLOY_FILES="-f ${DOCKER_COMPOSE_DEPLOY_BASE}"
                        if [ -f "${DOCKER_COMPOSE_DEPLOY_OVR}" ]; then
                            DEPLOY_FILES="$DEPLOY_FILES -f ${DOCKER_COMPOSE_DEPLOY_OVR}"
                        fi
                        echo "$DEPLOY_FILES" > .deploy_files
                        echo "Using compose files: $(cat .deploy_files)"
                    '''
                }
            }
        }
        stage('Deploy - Stop Services') {
          steps {
            dir("/workspace/biblioflow") {
                sh '''
                  # stop seulement les services d'app, pas Sonar
                  docker compose -p ${COMPOSE_PROJECT_NAME_DEPLOY} --project-directory /workspace/biblioflow $(cat .deploy_files) stop backend frontend postgres || true
                  docker compose -p ${COMPOSE_PROJECT_NAME_DEPLOY} --project-directory /workspace/biblioflow $(cat .deploy_files) rm -f backend frontend postgres || true
                '''
            }
          }
        }
        stage('Deploy - Build') {
            steps {
                dir("/workspace/biblioflow") {
                    sh 'docker compose -p ${COMPOSE_PROJECT_NAME_DEPLOY} --project-directory /workspace/biblioflow $(cat .deploy_files) build --no-cache backend frontend'
                }
            }
        }

        stage('Debug SonarScanner') {
            steps {
                script {
                    def scannerHome = tool 'SonarQube'
                    sh "echo 'Scanner home: ${scannerHome}'"
                    sh "ls -la ${scannerHome}/bin/"
                    sh "${scannerHome}/bin/sonar-scanner --version"
                }
            }
        }

        stage('Ensure Network Connection') {
            steps {
                sh '''
                    # Connecter Jenkins au réseau si pas déjà fait
                    docker network connect biblioflow_default biblioflow-jenkins 2>/dev/null || echo "Jenkins déjà connecté"

                    # Vérifier la connexion
                    docker network inspect biblioflow_default | grep biblioflow-jenkins
                '''
            }
        }

        stage('SonarQube Analysis') {
            steps {
                script {
                    def scannerHome = tool 'SonarQube'

                    withSonarQubeEnv('SonarQube') {
                        dir('/workspace/biblioflow/biblioflow-backend') {
                            sh 'npm install'
                            sh "${scannerHome}/bin/sonar-scanner"
                        }

                        dir('/workspace/biblioflow/biblioflow-frontend') {
                            sh 'npm install'
                            sh "${scannerHome}/bin/sonar-scanner"
                        }
                    }

                    echo "SonarQube analysis completed successfully for both projects"
                    echo "Check results at: http://localhost:9000"
                }
            }
        }

        stage('Deploy - Up') {
            steps {
                dir("/workspace/biblioflow") {
                    sh '''
                        # Démarrer postgres d'abord
                        docker compose -p ${COMPOSE_PROJECT_NAME_DEPLOY} --project-directory /workspace/biblioflow $(cat .deploy_files) up -d postgres

                        # Attente simple
                        echo "Waiting for PostgreSQL..."
                        sleep 30

                        # Démarrer le reste
                        docker compose -p ${COMPOSE_PROJECT_NAME_DEPLOY} --project-directory /workspace/biblioflow $(cat .deploy_files) up -d backend frontend

                        echo "Services started successfully"
                    '''
                }
            }
        }
        stage('Health Check') {
            steps {
                dir("/workspace/biblioflow") {
                    sh '''
                        echo "Waiting for services..."
                        sleep 30

                        echo "=== Container Status ==="
                        docker compose -p ${COMPOSE_PROJECT_NAME_DEPLOY} --project-directory /workspace/biblioflow $(cat .deploy_files) ps

                        echo "=== Backend Logs ==="
                        docker compose -p ${COMPOSE_PROJECT_NAME_DEPLOY} --project-directory /workspace/biblioflow $(cat .deploy_files) logs --tail=20 backend || true

                        echo "=== Frontend Logs ==="
                        docker compose -p ${COMPOSE_PROJECT_NAME_DEPLOY} --project-directory /workspace/biblioflow $(cat .deploy_files) logs --tail=20 frontend || true

                        echo "=== Testing Backend Health ==="
                        for i in {1..5}; do
                            if curl -f -s http://localhost:3000/health || curl -f -s http://localhost:3000/api/health || curl -f -s http://localhost:3000/; then
                                echo "✓ Backend responding!"
                                break
                            elif [ $i -eq 5 ]; then
                                echo "✗ Backend not responding after 5 attempts"
                            else
                                echo "Attempt $i/5..."
                                sleep 10
                            fi
                        done
                    '''
                }
            }
        }
    }
    post {
        // always {
        //     sh 'rm -f "/workspace/biblioflow/.env" /workspace/biblioflow/.deploy_files || true'
        // }
        failure {
            dir("/workspace/biblioflow") {
                sh 'docker compose -p ${COMPOSE_PROJECT_NAME_DEPLOY} --project-directory /workspace/biblioflow $(cat .deploy_files) logs --tail=50 || true'
            }
        }
    }
}
