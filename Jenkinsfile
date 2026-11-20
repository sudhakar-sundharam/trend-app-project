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
        stage('Deploy to EKS') {
    steps {
        sh '''
        aws eks update-kubeconfig --name trend-cluster --region ap-southeast-2
        kubectl apply -f k8s-dep.yml
        kubectl apply -f k8s-serv.yml
        kubectl set image deployment/trend-app trend-app=146364515119.dkr.ecr.ap-southeast-2.amazonaws.com/trend-app:${BUILD_NUMBER} || true
        kubectl rollout status deployment/trend-app
        '''
    }
        }
    }
}
