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
                git branch: 'main', url: 'https://github.com/MaorTaieb/k8s-web-hello.git'
                script {
                    env.IMAGE_TAG = sh(script: "git rev-parse --short HEAD", returnStdout: true).trim()
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    // Check Minikube status
                    def minikubeStatus = sh(script: 'minikube -p minikube status --format="{{.Host}}"', returnStdout: true).trim()
                    if (minikubeStatus != "Running") {
                        error("❌ Minikube is not running. Please start it first.")
                    }

                    // Capture Minikube Docker environment into a file
                    sh 'minikube -p minikube docker-env --shell bash > /tmp/minikube_env.sh'

                    // Source the environment file and build Docker image in the same shell
                    sh '''
                        set -e
                        source /tmp/minikube_env.sh
                        docker build -t ${IMAGE_NAME}:${IMAGE_TAG} .
                    '''
                }
            }
        }

        stage('Deploy to Minikube') {
            steps {
                script {
                    sh """
                        # Create namespace if not exists
                        kubectl create namespace ${NAMESPACE} --dry-run=client -o yaml | kubectl apply -f -
                        
                        # Apply deployment and service
                        kubectl apply -f k8s/deployment.yaml
                        kubectl apply -f k8s/service.yaml
                        
                        # Update deployment image
                        kubectl set image deployment/${DEPLOYMENT} ${DEPLOYMENT}=${IMAGE_NAME}:${IMAGE_TAG} -n ${NAMESPACE} --record
                        
                        # Wait for rollout
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
