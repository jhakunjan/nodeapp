pipeline {
    agent { label 'agent-linux' }
    
    tools{
        nodejs 'NodeJS_20' //ensure this should be configured in jenkins global tools
        
    }

    stages {
        stage('Setup Node.js Environment') {
            steps {
                echo ' Setting up Node.js on the agent...'
                sh 'node -v'
                sh 'npm -v'
            }
        }

        stage('Unit Test') {
            steps {                
                sh 'npm install --save-dev jest supertest'
                echo ' Running unit tests...'
                sh 'npm test'
                sh 'npm run coverage'

            }
        }

        stage('SonarQube Code Analysis') {
            steps {
                echo 'Running SonarQube scan...'
                withSonarQubeEnv('SonarQubeServer') {
                    sh 'npm run sonar'
                }
            }
        }

        stage('SonarQube Quality Gate') {
            steps {
                timeout(time: 5, unit: 'MINUTES') {  // Wait for up to 5 minutes
                    waitForQualityGate abortPipeline: true  // Abort if the quality gate fails
                }
            }
        }

        stage('Build Package') {
            steps {
                echo '📦 Building the application...'
                ///sh 'npm run build' // or any other build command
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
