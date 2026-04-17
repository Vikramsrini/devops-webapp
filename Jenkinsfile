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
                        docker stop test-container 2>/dev/null || true
                        docker rm test-container 2>/dev/null || true
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
                        # Copy kubeconfig to Jenkins home with proper permissions
                        mkdir -p ~/.kube
                        sudo cp /etc/rancher/k3s/k3s.yaml ~/.kube/config
                        sudo chown $(id -u):$(id -g) ~/.kube/config
                        sudo chmod 600 ~/.kube/config
                        export KUBECONFIG=~/.kube/config
                        
                        kubectl apply --validate=false -f k8s/deployment.yaml
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
                        # Verify deployment with kubectl
                        export KUBECONFIG=~/.kube/config
                        kubectl get pods -l app=myapp
                        kubectl get svc myapp-service
                        
                        # Get node IP
                        NODE_IP=15.135.82.142
                        NODE_PORT=30010
                        echo "Testing application at http://${NODE_IP}:${NODE_PORT}"
                        sleep 10
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
