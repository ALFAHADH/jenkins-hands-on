pipeline {
    agent any

    // ── ENVIRONMENT ─────────────────────────────────────────────────
    // Variables available to every stage
    // BUILD_NUMBER is auto-provided by Jenkins
    environment {
        APP_NAME    = 'my-jenkins-app'
        DEPLOY_USER = 'deployuser'
        DEPLOY_HOST = '<EC2_2_PRIVATE_IP>'   // ← change this
        DEPLOY_DIR  = '/opt/myapp'
        SSH_CRED_ID = 'deploy-server-ssh'   // matches credential ID you created
    }

    stages {

        // ════════════════════════════════════════════════════════════
        // STAGE 1: CHECKOUT
        // What:  Jenkins pulls your code from Git
        // Why:   Every build needs a fresh copy of the source code
        // ════════════════════════════════════════════════════════════
        stage('Checkout') {
            steps {
                echo "Checking out source code..."
                checkout scm
                // 'scm' means: use whatever Git URL is configured in the Jenkins job
                // Jenkins clones the repo into its workspace directory
                sh 'ls -la'   // verify files are there
            }
        }

        // ════════════════════════════════════════════════════════════
        // STAGE 2: BUILD
        // What:  Compile/package your application
        // Why:   Catches syntax errors, missing dependencies early
        //        Produces a deployable artifact (zip, jar, docker image)
        //
        // In real projects this could be:
        //   Java:   mvn clean package
        //   Node:   npm ci && npm run build
        //   Go:     go build ./...
        //   Docker: docker build -t myapp .
        // ════════════════════════════════════════════════════════════
        stage('Build') {
            steps {
                echo "=== BUILD STAGE ==="
                echo "App: ${APP_NAME} | Build #${BUILD_NUMBER}"
                sh '''
                    chmod +x scripts/build.sh
                    bash scripts/build.sh
                '''
                // After this, dist/app-package.zip exists in workspace
                echo "Build artifact created at dist/app-package.zip"
            }
        }

