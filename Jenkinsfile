pipeline {
    agent any
    environment {
        AWS_REGION = 'ap-southeast-2'
        ECR_REPO = '146364515119.dkr.ecr.ap-southeast-2.amazonaws.com/trend-app'
        CLUSTER = 'trend-cluster'
        IMAGE_TAG = "${BUILD_NUMBER}"
    }
    stages {
        stage('Clone') {
            steps {
                git branch: 'main', url: 'https://github.com/sudhakar-sundharam/trend-app-project.git'
            }
        }
        stage('Build & Push to ECR') {
            steps {
                sh '''
                aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin 146364515119.dkr.ecr.ap-southeast-2.amazonaws.com
                docker build -t $ECR_REPO:$IMAGE_TAG .
                docker build -t $ECR_REPO:latest .
                docker push $ECR_REPO:$IMAGE_TAG
                docker push $ECR_REPO:latest
                '''
            }
        }
        stage('Deploy to EKS') {
            steps {
                sh '''
                aws eks update-kubeconfig --name $CLUSTER --region $AWS_REGION
                kubectl set image deployment/trend-app trend-app=$ECR_REPO:$IMAGE_TAG --record || kubectl apply -f k8s/
                kubectl rollout status deployment/trend-app
                kubectl get svc
                '''
            }
        }
    }
}
