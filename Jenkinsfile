pipeline {
    agent any

    environment {
        IMAGE = "nicknihal54/capstone-website"
        TAG   = "${env.BUILD_NUMBER}"
    }

    parameters {
        booleanParam(name: 'FORCE_RELEASE', defaultValue: false,
                     description: 'Deploy to Kubernetes even if today is not the 25th (testing)')
    }

    triggers {
        githubPush()          // every push to GitHub -> build the Dockerfile
        cron('H 2 25 * *')    // monthly release run on the 25th
    }

    options {
        buildDiscarder(logRotator(numToKeepStr: '10'))
    }

    stages {
        stage('Checkout') {
            steps { checkout scm }
        }

        stage('Build Docker image') {
            steps { sh 'docker build -t $IMAGE:$TAG -t $IMAGE:latest .' }
        }

        stage('Push to Docker Hub') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub',
                                 usernameVariable: 'DH_U', passwordVariable: 'DH_P')]) {
                    sh '''
                        echo "$DH_P" | docker login -u "$DH_U" --password-stdin
                        docker push $IMAGE:$TAG
                        docker push $IMAGE:latest
                        docker logout
                    '''
                }
            }
        }

        stage('Release to Kubernetes (25th only)') {
            when {
                anyOf {
                    expression { sh(script: 'date +%d', returnStdout: true).trim() == '25' }
                    expression { params.FORCE_RELEASE }
                }
            }
            steps {
                sh '''
                    sed "s|IMAGE_PLACEHOLDER|$IMAGE:$TAG|" k8s/deployment.yaml | kubectl apply -f -
                    kubectl apply -f k8s/service.yaml
                    kubectl rollout status deployment/capstone-website --timeout=180s
                    kubectl get pods -l app=capstone-website -o wide
                    kubectl get svc capstone-website-svc
                '''
            }
        }
    }

    post {
        always { sh 'docker image prune -f || true' }
    }
}
