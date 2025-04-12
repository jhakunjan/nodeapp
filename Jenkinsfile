pipeline {
    agent { label 'Agent-1' }

    environment {
        // Define any environment variables if needed
        // e.g., SONAR_TOKEN = credentials('sonar-token-id')
    }

    stages {
        stage('Code Checkout') {
            steps {
                echo '✅ Checking out code...'
                checkout scm
            }
        }

        stage('Unit Test') {
            steps {
                echo '🧪 Running unit tests...'
                sh 'npm run test:unit' // Replace with your actual unit test script
            }
        }

        stage('Integration Test') {
            steps {
                echo '🔁 Running integration tests...'
                sh 'npm run test:integration' // Replace accordingly
            }
        }

        stage('SonarQube Code Analysis') {
            steps {
                echo '🔍 Running SonarQube scan...'
                withSonarQubeEnv('SonarQubeServer') {
                    sh 'npm run sonar' // Assumes sonar scanner is set up in your project
                }
            }
        }

        stage('SonarQube Quality Gate') {
            steps {
                echo '✅ Waiting for SonarQube Quality Gate...'
                timeout(time: 5, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }

        stage('Build Package') {
            steps {
                echo '📦 Building the application...'
                sh 'npm run build' // or any other build command
            }
        }

        stage('Push Package to Artifactory') {
            steps {
                echo '📤 Pushing package to Artifactory...'
                // Placeholder for Docker or npm publish or artifact push
                sh 'echo "Pushed to Artifactory!"'
            }
        }
    }

    post {
        success {
            echo '🎉 Pipeline completed successfully!'
        }
        failure {
            echo '❌ Pipeline failed!'
        }
    }
}
