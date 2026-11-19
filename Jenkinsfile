pipeline {
    agent any
    stages {
        stage('Clone') {
            steps {
                git branch: 'main', url: 'https://github.com/sudhakar-sundharam/trend-app-project.git'
            }
        }
        stage('Build') {
            steps {
                sh 'ls -la'
            }
        }
        stage('Deploy') {
            steps {
                sh 'docker build -t trend-app:latest . || echo "Dockerfile illa"'
                sh 'docker stop trend-app || true'
                sh 'docker rm trend-app || true'
                sh 'docker run -d --name trend-app -p 3000:3000 trend-app:latest || echo "Run failed"'
            }
        }
    }
}
