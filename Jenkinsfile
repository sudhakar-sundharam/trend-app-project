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
                cat > k8s-deply-yml <<'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: trend-app
spec:
  replicas: 2
  selector:
    matchLabels:
      app: trend-app
  template:
    metadata:
      labels:
        app: trend-app
    spec:
      containers:
            - name: trend-app
        image: 146364515119.dkr.ecr.ap-southeast-2.amazonaws.com/trend-app:latest
        ports:
                - containerPort: 80
EOF
                cat > k8s-serv-yml <<'EOF'
apiVersion: v1
kind: Service
metadata:
  name: trend-app-service
spec:
  type: LoadBalancer
  selector:
    app: trend-app
  ports:
    - port: 80
    targetPort: 80
EOF
                kubectl apply -f k8s-deply-yml
                kubectl apply -f k8s-serv-yml
                kubectl rollout status deployment/trend-app
                kubectl get svc trend-app-service
                '''
            }
        }
    }
}
