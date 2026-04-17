pipeline {
    agent any

    // ── ENVIRONMENT ─────────────────────────────────────────────────
    // Variables available to every stage
    // BUILD_NUMBER is auto-provided by Jenkins
    environment {
        APP_NAME    = 'my-jenkins-app'
        DEPLOY_USER = 'deployuser'
        DEPLOY_HOST = '172.31.12.148'   // ← change this
        DEPLOY_DIR  = '/opt/myapp'
        SSH_CRED_ID = 'deployuser'   // matches credential ID you created
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

        // ════════════════════════════════════════════════════════════
        // STAGE 3: TEST
        // What:  Run automated tests against the built code
        // Why:   Catch bugs BEFORE they reach your server
        //        Never deploy code that hasn't been tested
        //
        // In real projects:
        //   Unit tests:       pytest / JUnit / Jest
        //   Integration:      postman / newman / rest-assured
        //   Coverage report:  pytest --cov / jacoco
        //   Security scan:    bandit / OWASP / trivy
        // ════════════════════════════════════════════════════════════
        stage('Test') {
            steps {
                echo "=== TEST STAGE ==="
                sh '''
                    chmod +x scripts/test.sh
                    bash scripts/test.sh
                '''
            }
            // If any test fails, sh throws an error,
            // Jenkins marks the build FAILED, and Deploy never runs.
            // This is the safety gate.
        }

        // ════════════════════════════════════════════════════════════
        // STAGE 4: DEPLOY
        // What:  Copy code to App Server and restart the application
        // Why:   Gets the tested build running for real users
        //
        // Here we use SSH to reach EC2 #2.
        // Jenkins uses the credential 'deploy-server-ssh' we added earlier.
        //
        // In real projects:
        //   Simple:  scp + ssh (what we do here)
        //   Modern:  Ansible / Kubernetes / AWS CodeDeploy
        //   Docker:  docker pull && docker run
        // ════════════════════════════════════════════════════════════
        stage('Deploy') {
            steps {
                echo "=== DEPLOY STAGE ==="

                // sshagent loads the private key into the SSH agent
                // so subsequent ssh/scp commands can authenticate
                sshagent(credentials: [SSH_CRED_ID]) {

                    // Step A: Copy files to App Server
                    echo "Copying files to ${DEPLOY_HOST}..."
                    sh """
                        scp -o StrictHostKeyChecking=no -r app/ scripts/ requirements.txt \
                            ${DEPLOY_USER}@${DEPLOY_HOST}:${DEPLOY_DIR}/
                    """

                    // Step B: Run deploy script on App Server over SSH
                    echo "Running deploy script on App Server..."
                    sh """
                        ssh -o StrictHostKeyChecking=no \
                            ${DEPLOY_USER}@${DEPLOY_HOST} \
                            'cd ${DEPLOY_DIR} && bash scripts/deploy.sh'
                    """

                    // Step C: Verify the app is up
                    echo "Verifying deployment..."
                    sh """
                        ssh -o StrictHostKeyChecking=no \
                            ${DEPLOY_USER}@${DEPLOY_HOST} \
                            'curl -s http://localhost:5000/health'
                    """
                }
            }
        }
    }

    // ── POST ACTIONS ──────────────────────────────────────────────
    // Runs after all stages — regardless of success or failure
    post {
        success {
            echo "PIPELINE SUCCEEDED — Build #${BUILD_NUMBER} deployed!"
        }
        failure {
            echo "PIPELINE FAILED — Check the logs above for errors."
        }
        always {
            // Archive the build artifact so you can download it from Jenkins UI
            archiveArtifacts artifacts: 'dist/*.zip', allowEmptyArchive: true
            echo "Pipeline finished."
        }
    }
}
