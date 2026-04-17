pipeline {
    agent any
    
    environment {
        DOCKER_IMAGE = "myapp"
        DOCKER_TAG = "${BUILD_NUMBER}"
    }
    
    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/Vikramsrini/devops-webapp.git'
            }
        }
        
        stage('Build Docker Image') {
            steps {
                script {
                    sh "docker build -t ${DOCKER_IMAGE}:${DOCKER_TAG} ."
                    sh "docker tag ${DOCKER_IMAGE}:${DOCKER_TAG} ${DOCKER_IMAGE}:latest"
                }
            }
        }
        
        stage('Test') {
            steps {
                script {
                    sh '''
                        echo "Running container tests..."
                        docker run -d --name test-container -p 8081:80 ${DOCKER_IMAGE}:${DOCKER_TAG}
                        sleep 5
                        curl -f http://localhost:8081 || exit 1
                        docker stop test-container
                        docker rm test-container
                    '''
                }
            }
        }
        
        stage('Deploy to Kubernetes') {
            steps {
                script {
                    sh '''
                        kubectl apply -f k8s/deployment.yaml
                        kubectl set image deployment/myapp myapp=${DOCKER_IMAGE}:${DOCKER_TAG}
                        kubectl rollout status deployment/myapp
                        kubectl get pods -l app=myapp
                        kubectl get svc myapp-service
                    '''
                }
            }
        }
        
        stage('Verify Deployment') {
            steps {
                script {
                    sh '''
                        NODE_IP=$(curl -s ifconfig.me)
                        NODE_PORT=30010
                        echo "Testing application at http://${NODE_IP}:${NODE_PORT}"
                        curl -f http://${NODE_IP}:${NODE_PORT} || exit 1
                        echo "Deployment verified successfully!"
                    '''
                }
            }
        }
    }
    
    post {
        always {
            sh "docker system prune -f || true"
        }
        success {
            echo "Pipeline completed successfully!"
        }
        failure {
            echo "Pipeline failed!"
        }
    }
}
