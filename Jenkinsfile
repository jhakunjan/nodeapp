pipeline {
    agent any
    
    tools{
        nodejs 'NodeJS_20' //ensure this should be configured in jenkins global tools
        
    }

    options {
        buildDiscarder(logRotator(numToKeepStr: '10', daysToKeepStr: '30'))
    }

    triggers {
        // Scheduled builds - Every Wednesday and Friday at 5 PM IST
        cron('H 11 * * 3,5') 

         
        githubPush()
    }

    environment {
        ARTIFACTORY_URL = 'https://trialbag95d.jfrog.io/artifactory/sampleapp-npm-local'
        ARTIFACTORY_REPO = 'sampleapp-npm'
        PACKAGE_NAME = "node-app-package.tar-0.0.${BUILD_NUMBER}.gz"  
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
                timeout(time: 10, unit: 'MINUTES') {  // Wait for up to 10 minutes
                    waitForQualityGate abortPipeline: false // Abort if the quality gate fails
                }
            }
        }

        stage('Build Package') {
            steps {
                sh '''
                    npm install

                    mkdir -p dist
                    cp server.js package.json package-lock.json dist/
                    [ -d views ] && cp -r views dist/
                    [ -d public ] && cp -r public dist/

                    tar -czf "$PACKAGE_NAME" -C dist .
                '''

                archiveArtifacts artifacts: "${PACKAGE_NAME}", fingerprint: true 
            }
        }

        stage('Push Package to Artifactory') {
            steps {
                echo 'Uploading artifacts with folder structure using JF_ACCESS_TOKEN...'

                withCredentials([string(credentialsId: 'JF_ACCESS_TOKEN', variable: 'TOKEN')]) {
                    sh '''
                        echo "Uploading $PACKAGE_NAME to Artifactory..."
                        curl -H "Authorization: Bearer $TOKEN" \
                             -T "$PACKAGE_NAME" \
                             "$ARTIFACTORY_URL/$PACKAGE_NAME"
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
