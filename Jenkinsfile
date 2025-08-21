pipeline {
    agent any
    options {
        disableConcurrentBuilds()
    }
    tools {
        nodejs "Node_24"
    }
    environment {
        DOCKER_COMPOSE_DEPLOY_BASE = "${WORKSPACE}/compose.yml"
        DOCKER_COMPOSE_DEPLOY_OVR = "${WORKSPACE}/compose.ci.yml"
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
                dir("${WORKSPACE}") {
                    sh 'test -f ${DOCKER_COMPOSE_DEPLOY_BASE} && echo "OK: compose.yml found" || (echo "ERROR: compose.yml missing" && exit 1)'
                    sh '[ -f ${DOCKER_COMPOSE_DEPLOY_OVR} ] && echo "compose.ci.yml present (will be used)" || echo "compose.ci.yml not present (will be skipped)"'
                }
            }
        }
        stage('Prepare Environment') {
            steps {
                sh '''
                    cat > "${WORKSPACE}/.env" << EOF
DB_NAME=bibliflow_ci
DB_USER=bibliflow_user
DB_PASSWORD=ci_password
JWT_SECRET=ci-test-secret-key
BACKEND_PORT=3000
FRONTEND_PORT=4200
API_URL=http://backend:3000/api/v1
NODE_ENV=test
EOF
                    chmod 600 "${WORKSPACE}/.env"
                    echo "✓ .env created for CI"
                '''
            }
        }
        stage('Assemble deploy compose files') {
            steps {
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
        stage('Deploy - Stop Services') {
            steps {
                sh 'docker compose -p ${COMPOSE_PROJECT_NAME_DEPLOY} --project-directory ${WORKSPACE} $(cat .deploy_files) down -v || true'
            }
        }
        stage('Deploy - Build') {
            steps {
                sh 'docker compose -p ${COMPOSE_PROJECT_NAME_DEPLOY} --project-directory ${WORKSPACE} $(cat .deploy_files) build --no-cache backend frontend'
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

        stage('SonarQube Analysis') {
            steps {
                script {
                    def scannerHome = tool 'SonarQube'

                    withSonarQubeEnv('SonarQube') {
                        dir('bibliflow-backend') {
                            sh 'npm install'
                            sh "${scannerHome}/bin/sonar-scanner"
                        }

                        dir('bibliflow-frontend') {
                            sh 'npm install'
                            sh "${scannerHome}/bin/sonar-scanner"
                        }
                    }

                    timeout(time: 2, unit: 'MINUTES') {
                        waitForQualityGate abortPipeline: true
                    }
                }
            }
        }

        stage('Deploy - Up') {
            steps {
                sh '''
                    # Démarrer postgres d'abord
                    docker compose -p ${COMPOSE_PROJECT_NAME_DEPLOY} --project-directory ${WORKSPACE} $(cat .deploy_files) up -d postgres

                    # Attente simple
                    echo "Waiting for PostgreSQL..."
                    sleep 30

                    # Démarrer le reste
                    docker compose -p ${COMPOSE_PROJECT_NAME_DEPLOY} --project-directory ${WORKSPACE} $(cat .deploy_files) up -d backend frontend

                    echo "Services started successfully"
                '''
            }
        }
        stage('Health Check') {
            steps {
                sh '''
                    echo "Waiting for services..."
                    sleep 30

                    echo "=== Container Status ==="
                    docker compose -p ${COMPOSE_PROJECT_NAME_DEPLOY} --project-directory ${WORKSPACE} $(cat .deploy_files) ps

                    echo "=== Backend Logs ==="
                    docker compose -p ${COMPOSE_PROJECT_NAME_DEPLOY} --project-directory ${WORKSPACE} $(cat .deploy_files) logs --tail=20 backend || true

                    echo "=== Frontend Logs ==="
                    docker compose -p ${COMPOSE_PROJECT_NAME_DEPLOY} --project-directory ${WORKSPACE} $(cat .deploy_files) logs --tail=20 frontend || true

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
    post {
        always {
            sh 'rm -f "${WORKSPACE}/.env" .deploy_files || true'
        }
        failure {
            sh 'docker compose -p ${COMPOSE_PROJECT_NAME_DEPLOY} --project-directory ${WORKSPACE} $(cat .deploy_files) logs --tail=50 || true'
        }
    }
}
