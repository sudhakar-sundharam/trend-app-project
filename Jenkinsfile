pipeline {
    agent any
    environment {
        AWS_REGION = 'ap-southeast-2'
        ECR_REPO = 'YOUR_ECR_REPO_URI'
        CLUSTER = 'YOUR_CLUSTER_NAME'
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
                aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $ECR_REPO
                docker build -t $ECR_REPO:latest .
                docker push $ECR_REPO:latest
                '''
            }
        }
        stage('Deploy to EKS') {
            steps {
                sh '''
                aws eks update-kubeconfig --name $CLUSTER --region $AWS_REGION
                kubectl set image deployment/trend-app trend-app=$ECR_REPO:latest || kubectl create deployment trend-app --image=$ECR_REPO:latest
                kubectl expose deployment trend-app --port=80 --type=LoadBalancer || true
                kubectl rollout status deployment/trend-app
                '''
            }
        }
    }
}
