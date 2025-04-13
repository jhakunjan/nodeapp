pipeline {
    agent { label 'agent-linux' }
    
    tools{
        nodejs 'NodeJS_20' //ensure this should be configured in jenkins global tools
        
    }
    environment {
        ARTIFACTORY_URL = 'https://trial7fyb86.jfrog.io/artifactory/nodeapp-npm/'
        ARTIFACTORY_REPO = 'nodeapp-npm'  
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
                sh 'npm install --save-dev sonar-scanner'
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
                sh 'npm install'
                echo ' Building the application...'
                sh 'npm run build' 
            }
        }

        stage('Push Package to Artifactory') {
            steps {
                echo 'Uploading artifacts with folder structure using JF_ACCESS_TOKEN...'

                withCredentials([string(credentialsId: 'JF_ACCESS_TOKEN', variable: 'TOKEN')]) {
                    sh '''
                        find dist -type f | while read file; do
                            rel_path="${file#dist/}"
                            curl -H "Authorization: Bearer $TOKEN" \
                                 -T "$file" \
                                 "$ARTIFACTORY_URL/$rel_path"
                        done
                    '''
                }
            }
        }       
    }

    post {
        success {
            echo ' Pipeline completed successfully!'
        }
        failure {
            echo ' Pipeline failed!'
        }
    }
}
