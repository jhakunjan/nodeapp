pipeline {
    agent any

    tools {
        nodejs 'NodeJS_20'
    }

    options {
        buildDiscarder(logRotator(numToKeepStr: '10', daysToKeepStr: '3'))
    }

    environment {
        ARTIFACTORY_URL = 'https://trialbag95d.jfrog.io/artifactory/sampleapp-npm'
        ARTIFACTORY_REPO = 'sampleapp-npm'
        PACKAGE_NAME = "node-app-package.tar-0.0.${BUILD_NUMBER}.gz"
        EC2_HOST = "ec2-43-204-234-162.ap-south-1.compute.amazonaws.com"
    }

    parameters {
        choice(name: 'DEPLOY_ENV', choices: ['local'], description: 'Where do you want to deploy?')
    }

    stages {
        stage('Setup Node.js') {
            steps {
                sh 'node -v'
                sh 'npm -v'
            }
        }

        stage('Run tests') {
            parallel {
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
                timeout(time: 5, unit: 'MINUTES') {
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
                input message: "Approve deployment to ${params.DEPLOY_ENV} environment?", ok: 'Deploy'
            }
        }

        stage('Deploy') {
            steps {
                withCredentials([string(credentialsId: 'JF_ACCESS_TOKEN', variable: 'TOKEN')]) {
                    script {
                        if (params.DEPLOY_ENV == 'local') {
                            echo "Deploying to LOCAL environment..."
                                sh '''
                                    REMOTE_DIR="$WORKSPACE/app"

                                    echo "Downloading artifact from Artifactory..."
                                    curl -H "Authorization: Bearer $TOKEN" -o /tmp/$PACKAGE_NAME "$ARTIFACTORY_URL/$PACKAGE_NAME"

                                    echo "Preparing deployment directory..."
                                    pkill -f "node server.js" || true
                                    rm -rf "$REMOTE_DIR"
                                    mkdir -p "$REMOTE_DIR"

                                    echo "Extracting artifact..."
                                    tar -xzf /tmp/$PACKAGE_NAME -C "$REMOTE_DIR"

                                    echo "Installing dependencies..."
                                    cd "$REMOTE_DIR"
                                    npm install

                                    echo "Installing PM2 and starting the app..."
                                    npm install -g pm2
                                    pm2 start server.js --name node-app
                                    pm2 save
                                    pm2 startup | tail -n 1 | bash
                                '''                     
                             
                               
                        
                        } 
                        else {
                            error("Unknown deployment environment: ${params.DEPLOY_ENV}")
                        }
                    }
                }
            }
        }

        stage('Smoke Test') {
            steps {
                echo "Verifying app is accessible..."
                sh 'curl --silent --fail http://localhost:3000/ || exit 1'
                sleep(180)
            }
        }
    }

    post {
        success {
            echo 'Deployment Successful!'
        }
        failure {
            echo 'Deployment Failed'
        }
        always {
            echo 'Cleaning Jenkins workspace...'
            cleanWs()
        }
    }
}
