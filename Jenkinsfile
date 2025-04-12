pipelines{
    agent{node(label:"Agent-1")}
    stages{
        stage('Code checkout'){
            steps{
                echo "step1"
            }
        }
        stage('Unit test'){
            steps{
                echo "step2"
            }
        }
        stage('Integeration test'){
            steps{
                echo "step3"
            }
        }
        stage('Sonar code analysis'){
            steps{
                echo "step4"
            }
        }
        stage('Sonar quality gates'){
            steps{
                echo "step5"
            }
        }
        stage('Build package'){
            steps{
                echo "step6"
            }
        }
        stage('Push package to artifacts'){
            steps{
                echo "step7"

            }
        }
    }
}