pipeline {
    agent any

    environment {
        APP_NAME    = 'my-jenkins-app'
        DEPLOY_USER = 'deployuser'
        DEPLOY_HOST = '172.31.12.148'
        DEPLOY_DIR  = '/opt/myapp'
        SSH_CRED_ID = 'deployuser'
    }

    stages {

        // ─────────────────────────────
        // STAGE 1: CHECKOUT
        // ─────────────────────────────
        stage('Checkout') {
            steps {
                echo "Checking out source code..."
                checkout scm
                sh 'ls -la'
            }
        }

        // ─────────────────────────────
        // STAGE 2: SETUP PYTHON (FIX)
        // ─────────────────────────────
        stage('Setup Python') {
            steps {
                sh '''
                set -e

                echo "Checking if python3-venv is available..."

                if ! python3 -m venv testenv 2>/dev/null; then
                    echo "python3-venv missing. Installing..."

                    if command -v sudo >/dev/null 2>&1; then
                        sudo apt update
                        sudo apt install -y python3-venv
                    else
                        echo "ERROR: sudo not available. Install python3-venv manually."
                        exit 1
                    fi
                else
                    echo "python3-venv already installed."
                fi

                rm -rf testenv
                '''
            }
        }

        // ─────────────────────────────
        // STAGE 3: BUILD
        // ─────────────────────────────
        stage('Build') {
            steps {
                echo "=== BUILD STAGE ==="
                echo "App: ${APP_NAME} | Build #${BUILD_NUMBER}"

                sh '''
                set -e
                chmod +x scripts/build.sh
                bash scripts/build.sh
                '''
            }
        }

        // ─────────────────────────────
        // STAGE 4: TEST
        // ─────────────────────────────
        stage('Test') {
            steps {
                echo "=== TEST STAGE ==="
                sh '''
                set -e
                chmod +x scripts/test.sh
                bash scripts/test.sh
                '''
            }
        }

        // ─────────────────────────────
        // STAGE 5: DEPLOY
        // ─────────────────────────────
        stage('Deploy') {
            steps {
                echo "=== DEPLOY STAGE ==="

                sshagent(credentials: [SSH_CRED_ID]) {

                    sh """
                        echo "Copying files to ${DEPLOY_HOST}..."

                        ssh -o StrictHostKeyChecking=no ${DEPLOY_USER}@${DEPLOY_HOST} \
                        'mkdir -p ${DEPLOY_DIR}'

                        scp -o StrictHostKeyChecking=no -r app/ scripts/ requirements.txt \
                        ${DEPLOY_USER}@${DEPLOY_HOST}:${DEPLOY_DIR}/
                    """

                    sh """
                        echo "Running deploy script..."

                        ssh -o StrictHostKeyChecking=no \
                        ${DEPLOY_USER}@${DEPLOY_HOST} \
                        'cd ${DEPLOY_DIR} && chmod +x scripts/deploy.sh && bash scripts/deploy.sh'
                    """

                    sh """
                        echo "Verifying deployment..."

                        ssh -o StrictHostKeyChecking=no \
                        ${DEPLOY_USER}@${DEPLOY_HOST} \
                        'curl -s http://localhost:5000/health || echo "Health check failed"'
                    """
                }
            }
        }
    }

    // ─────────────────────────────
    // POST ACTIONS
    // ─────────────────────────────
    post {
        success {
            echo "PIPELINE SUCCEEDED — Build #${BUILD_NUMBER} deployed!"
        }
        failure {
            echo "PIPELINE FAILED — Check logs."
        }
        always {
            archiveArtifacts artifacts: 'dist/*.zip', allowEmptyArchive: true
            echo "Pipeline finished."
        }
    }
}
