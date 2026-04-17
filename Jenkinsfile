pipeline {
    agent any

    environment {
        APP_NAME    = 'my-jenkins-app'
        DEPLOY_USER = 'deployuser'
        DEPLOY_HOST = '172.31.12.148'
        DEPLOY_DIR  = '/opt/myapp'
        SSH_CRED_ID = 'deploy-server-ssh'
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
        // STAGE 2: SETUP DEPENDENCIES
        // ─────────────────────────────
        stage('Setup Dependencies') {
            steps {
                sh '''
                set -e

                echo "==== INSTALLING REQUIRED PACKAGES ===="

                sudo apt update

                # python venv
                if ! python3 -m venv testenv 2>/dev/null; then
                    echo "[FIX] Installing python3-venv..."
                    sudo apt install -y python3-venv
                else
                    echo "[OK] python3-venv already installed"
                fi
                rm -rf testenv

                # zip
                if ! command -v zip >/dev/null 2>&1; then
                    echo "[FIX] Installing zip..."
                    sudo apt install -y zip
                else
                    echo "[OK] zip already installed"
                fi

                echo "==== SETUP COMPLETE ===="
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
        // STAGE 5: DEPLOY (UPDATED)
        // ─────────────────────────────
        stage('Deploy') {
            steps {
                echo "=== DEPLOY STAGE ==="

                sshagent(credentials: [SSH_CRED_ID]) {

                    // Create directory with sudo
                    sh """
                    echo "Creating directory on remote server..."
                    ssh -o StrictHostKeyChecking=no ${DEPLOY_USER}@${DEPLOY_HOST} \
                    'sudo mkdir -p ${DEPLOY_DIR} && sudo chown -R ${DEPLOY_USER}:${DEPLOY_USER} ${DEPLOY_DIR}'
                    """

                    // Copy files
                    sh """
                    echo "Copying files to server..."
                    scp -o StrictHostKeyChecking=no -r app/ scripts/ requirements.txt \
                    ${DEPLOY_USER}@${DEPLOY_HOST}:${DEPLOY_DIR}/
                    """

                    // Run deploy script
                    sh """
                    echo "Running deploy script..."
                    ssh -o StrictHostKeyChecking=no \
                    ${DEPLOY_USER}@${DEPLOY_HOST} \
                    'cd ${DEPLOY_DIR} && chmod +x scripts/deploy.sh && sudo bash scripts/deploy.sh'
                    """

                    // Health check
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
