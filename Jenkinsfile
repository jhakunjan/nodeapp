pipeline {
    agent any

    tools {
        nodejs 'NodeJS_20'
    }

    options {
        buildDiscarder(logRotator(numToKeepStr: '10', daysToKeepStr: '30'))
    }

    environment {
        ARTIFACTORY_URL = 'https://trialbag95d.jfrog.io/artifactory/sampleapp-npm'
        ARTIFACTORY_REPO = 'sampleapp-npm'
        PACKAGE_NAME = "node-app-package.tar-0.0.${BUILD_NUMBER}.gz"
    }

    stages {
        stage('Setup Node.js') {
            steps {
                sh 'node -v'
                sh 'npm -v'
            }
        }

        stage('Run tests'){
            parallel{
                stage('Unit Test') {
                    steps {
                        sh 'npm install --save-dev jest supertest'
                        sh 'npm test'
                        sh 'npm run coverage'
                    }
                }

                stage('SonarQube Scan') {
                    steps {
                        sh 'npm install --save-dev sonar-scanner'
                        withSonarQubeEnv('SonarQubeServer') {
                            sh 'npm run sonar'
                        }
                    }
                }
            }
        }

        stage('SonarQube Quality Gate') {
            steps {
                timeout(time: 10, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: false
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

        stage('Push to Artifactory') {
            steps {
                withCredentials([string(credentialsId: 'JF_ACCESS_TOKEN', variable: 'TOKEN')]) {
                    sh '''
                        curl -H "Authorization: Bearer $TOKEN" \
                             -T "$PACKAGE_NAME" \
                             "$ARTIFACTORY_URL/$PACKAGE_NAME"
                    '''
                }
            }
        }

        stage('Approval') {
            steps {
                input message: 'Approve deployment to local environment?', ok: 'Deploy'
            }
        }

        stage('Deploy Locally') {
            steps {
                withCredentials([string(credentialsId: 'JF_ACCESS_TOKEN', variable: 'TOKEN')]) {
                    sh '''
                        echo "Preparing deployment..."

                        DEPLOY_DIR="/opt/node-app"

                        
                        echo "Downloading artifact..."
                        curl -H "Authorization: Bearer $TOKEN" -o $DEPLOY_DIR/$PACKAGE_NAME "$ARTIFACTORY_URL/$PACKAGE_NAME"

                        echo "Stopping old Node.js process..."
                        pkill -f "node server.js" || true

                        echo "Extracting new build..."
                        rm -rf $DEPLOY_DIR/app
                        mkdir -p $DEPLOY_DIR/app
                        tar -xzf $DEPLOY_DIR/$PACKAGE_NAME -C $DEPLOY_DIR/app

                        echo "Installing dependencies..."
                        cd $DEPLOY_DIR/app
                        npm install

                        echo "Starting Node.js server..."
                        nohup node server.js > $DEPLOY_DIR/app.log 2>&1 &
                    '''
                }
            }
        }


        stage('Smoke Test') {
            steps {
                echo "Verifying app is accessible..."
                sh 'curl --silent --fail http://localhost:3000/ || exit 1'
            }
        }
    }

    post {
        success {
            echo ' Local Deployment Successful!'
        }
        failure {
            echo ' Deployment Failed'
        }
        always {
        echo 'Cleaning Jenkins workspace...'
        cleanWs()
    }
    }
}
