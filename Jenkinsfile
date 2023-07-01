pipeline {
  agent any
  tools { 
      maven 'M2_HOME' 
      jdk 'JAVA_HOME'
  }
  environment {
    DOCKERHUB_CREDENTIALS = credentials('docker_hub_credentials')
    DEV_EC2_SERVER = '44.202.87.2'
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
    stage('Clone SoureCode') {
      steps {
        git branch: 'main', url: 'https://github.com/sreenutech18/spring-boot-sample-app.git'

      }
    }

   // Build Java application

    stage('Build') {
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

    stage('Unit Test') {
      steps {
        sh 'mvn test'
      }
    }
    //sonarque server
    stage("SonarQube analysis") {
	    steps {
		  
		sh 'mvn sonar:sonar -Dsonar.host.url=http://44.202.87.2:9000/ -Dsonar.login=squ_c63dd06d54fa172631a30dd1a8781dd049132c4a'
		       
	      }
      }

   // Build docker image in Jenkins

    stage('Prepare Image') {

      steps {
        sh 'docker build -t javawebapp:latest .'
        sh 'docker tag javawebapp sreenivas18/javawebapp:latest'
      
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
        sh 'docker push sreenivas18/javawebapp:latest'
      }
      post {
        always {
          sh 'docker logout'
        }
      }

    }

   // Pull docker image from DockerHub and run in EC2 instance 

    stage('Dev Environment') {
      steps {
        script {
          sshagent(credentials: ['awscred']) {
          sh "ssh -o StrictHostKeyChecking=no ${DEV_EC2_USER}@${DEV_EC2_SERVER} 'docker stop javawebapp-dev || true && docker rm javawebapp-dev || true'"
      sh "ssh -o StrictHostKeyChecking=no ${DEV_EC2_USER}@${DEV_EC2_SERVER} 'docker pull sreenivas18/javawebapp'"
          sh "ssh -o StrictHostKeyChecking=no ${DEV_EC2_USER}@${DEV_EC2_SERVER} 'docker run --name javawebapp-dev -d -p 8081:8081 sreenivas18/javawebapp'"
          }
        }
      }
    }
    // Pull docker image from DockerHub and run in stage EC2 instance 
      stage('Test Environment') {
        
      steps {
       script {
               def userInput = input(id: 'Proceed1', message: 'Promote build?', parameters: [[$class: 'BooleanParameterDefinition', defaultValue: true, description: '', name: 'Please confirm you agree with this']])
               echo 'userInput: ' + userInput
               if(userInput == true) {
                    sshagent(credentials: ['awscred']) {
                      sh "ssh -o StrictHostKeyChecking=no ${DEV_EC2_USER}@${DEV_EC2_SERVER} 'docker stop javawebapp-test || true && docker rm javawebapp-test || true'"
                      sh "ssh -o StrictHostKeyChecking=no ${DEV_EC2_USER}@${DEV_EC2_SERVER} 'docker pull sreenivas18/javawebapp'"
                      sh "ssh -o StrictHostKeyChecking=no ${DEV_EC2_USER}@${DEV_EC2_SERVER} 'docker run --name javawebapp-test -d -p 8082:8081 sreenivas18/javawebapp'"
                    }
                } else {
                    // not do action
                 echo "Action was aborted."
                }
          
        }
      }
    }
  }
}
