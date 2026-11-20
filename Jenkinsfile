   pipeline {
    agent any
    environment {
        AWS_REGION = 'ap-southeast-2'
        ECR_REPO = '146364515119.dkr.ecr.ap-southeast-2.amazonaws.com/trend-app'
        CLUSTER_NAME = 'trend-cluster'
    }
    stages {
        stage('Clone') {
            steps {
                git url: 'https://github.com/sudhakar-sundharam/trend-app-project.git', branch: 'main'
            }
        }
        stage('Build & Push to ECR') {
            steps {
                sh '''
                aws ecr get-login-password --region ap-southeast-2 | docker login --username AWS --password-stdin 146364515119.dkr.ecr.ap-southeast-2.amazonaws.com
                docker build -t 146364515119.dkr.ecr.ap-southeast-2.amazonaws.com/trend-app:${BUILD_NUMBER} .
                docker build -t 146364515119.dkr.ecr.ap-southeast-2.amazonaws.com/trend-app:latest .
                docker push 146364515119.dkr.ecr.ap-southeast-2.amazonaws.com/trend-app:${BUILD_NUMBER}
                docker push 146364515119.dkr.ecr.ap-southeast-2.amazonaws.com/trend-app:latest
                '''
            }
        }
        stage('Deploy to EKS') {
            steps {
                sh '''
                aws eks update-kubeconfig --name trend-cluster --region ap-southeast-2
                kubectl apply -f k8s-dep-yml
                kubectl apply -f k8s-serv-yml
                kubectl set image deployment/trend-app trend-app=146364515119.dkr.ecr.ap-southeast-2.amazonaws.com/trend-app:${BUILD_NUMBER} || true
                kubectl rollout status deployment/trend-app
                '''
            }
        }
    }
}
