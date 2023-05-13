pipeline {
  agent any
  tools { 
      maven 'M2_HOME' 
      jdk 'JAVA_HOME'
      'org.jenkinsci.plugins.docker.commons.tools.DockerTool' 'docker'
  }
  environment {
    DOCKERHUB_CREDENTIALS = credentials('docker_hub_credentials')
    DEV_EC2_SERVER = '13.232.147.101'
    DEV_EC2_USER = 'ec2-user'            
  }

  // Fetch code from GitHub

  stages {
    stage ('Initialize') {
      steps {
          sh '''
              echo "PATH = ${PATH}"
              echo "M2_HOME = ${M2_HOME}"
          ''' 
      }
    }
    stage('Code Checkout') {
      steps {
        git branch: 'main', url: 'https://github.com/pradeep-kalidindi/spring-boot-sample-app.git'

      }
    }

   // Build Java application

    stage('Maven Build') {
      steps {
        sh 'mvn clean install'
      }

     // Post building archive Java application

      post {
        success {
          archiveArtifacts artifacts: '**/target/*.jar'
        }
      }
    }

  // Test Java application

    stage('Maven Test') {
      steps {
        sh 'mvn test'
      }
    }

   // Build docker image in Jenkins

    stage('Build Docker Image') {

      steps {
        sh 'docker build -t javawebapp:latest .'
        sh 'docker tag javawebapp pradeepkalidindi/javawebapp:latest'
      }
    }

   // Login to DockerHub before pushing docker Image

    stage('Login to DockerHub') {
      steps {
        sh 'echo $DOCKERHUB_CREDENTIALS_PSW | docker login -u    $DOCKERHUB_CREDENTIALS_USR --password-stdin'
      }
    }

   // Push image to DockerHub registry

    stage('Push Image to dockerHUb') {
      steps {
        sh 'docker push pradeepkalidindi/javawebapp:latest'
      }
      post {
        always {
          sh 'docker logout'
        }
      }

    }

   // Pull docker image from DockerHub and run in EC2 instance 

    stage('Deploy Docker image to DEV EC2') {
      steps {
        script {
          sshagent(credentials: ['awscred']) {
          sh "ssh -o StrictHostKeyChecking=no ${DEV_EC2_USER}@${DEV_EC2_SERVER} 'docker stop javawebapp || true && docker rm javawebapp || true'"
      sh "ssh -o StrictHostKeyChecking=no ${DEV_EC2_USER}@${DEV_EC2_SERVER} 'docker pull pradeepkalidindi/javawebapp'"
          sh "ssh -o StrictHostKeyChecking=no ${DEV_EC2_USER}@${DEV_EC2_SERVER} 'docker run --name javawebapp -d -p 8081:8081 pradeepkalidindi/javawebapp'"
          }
        }
      }
    }
  }
}
