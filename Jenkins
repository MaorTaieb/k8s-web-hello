pipeline {
    agent any

    environment {
        IMAGE_NAME = "k8s-web-hello"
        NAMESPACE  = "default"
        DEPLOYMENT = "k8s-hello-web1"
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/MaorTaieb/k81-web-hello.git'
                script {
                    env.IMAGE_TAG = sh(script: "git rev-parse --short HEAD", returnStdout: true).trim()
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    sh '''
                    #!/bin/bash
                    eval $(minikube -p minikube docker-env)
                    docker build -t ${IMAGE_NAME}:${IMAGE_TAG} .
                    '''
                }
            }
        }

        stage('Deploy to Minikube') {
            steps {
                script {
                    sh """
                        kubectl create namespace ${NAMESPACE} --dry-run=client -o yaml | kubectl apply -f -
                        kubectl apply -f k8s/deployment.yaml
                        kubectl apply -f k8s/service.yaml
                        kubectl set image deployment/${DEPLOYMENT} ${DEPLOYMENT}=${IMAGE_NAME}:${IMAGE_TAG} -n ${NAMESPACE} --record
                        kubectl rollout status deployment/${DEPLOYMENT} -n ${NAMESPACE} --timeout=120s
                    """
                }
            }
        }
    }

    post {
        success {
            echo "✅ Deployment successful!"
        }
        failure {
            echo "❌ Deployment failed!"
        }
    }
}
