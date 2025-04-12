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
                timeout(time: 5, unit: 'MIN
