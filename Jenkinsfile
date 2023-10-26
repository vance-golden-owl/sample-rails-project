pipeline {
  agent any

  stages {
    stage("Building") {
      steps {
        sh 'docker compose -f docker-compose.test.yml up -d --build'
      }
    }

    stage("Run test") {
      steps {
        sh '''
          docker exec sample-rails-project-web-1 bundle exec rubocop
          docker exec sample-rails-project-web-1 bundle exec rspec
        '''
      }
    }

    stage("Deployment") {
      when {
        branch "main"
      }

      environment {
        DOCKERHUB_CREDENTIALS = credentials('dockerhub')
      }

      stages {
        stage("Build image for production environment") {
          steps {
            sh 'docker build -f Dockerfile.prod -t $DOCKERHUB_CREDENTIALS_USR/sample-web . --no-cache'
          }
        }

        stage("Push image to Dockerhub") {
          steps {
            sh 'echo $DOCKERHUB_CREDENTIALS_PSW | docker login -u $DOCKERHUB_CREDENTIALS_USR --password-stdin'
            sh 'docker push $DOCKERHUB_CREDENTIALS_USR/sample-web'
          }
        }
      }
    }
  }

  post {
    always {
      sh 'docker compose -f docker-compose.test.yml down --remove-orphans -v'
      sh 'docker logout'
    }
  }
}
