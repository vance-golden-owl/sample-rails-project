pipeline {
  agent any

  environment {
    DOCKERHUB_CREDENTIALS = credentials('dockerhub')
  }

  stages {
    stage("Verify tooling") {
      steps {
        sh '''
          docker version
          docker info
          docker compose version
          curl --version
        '''
      }
    }

    stage ("Prune system") {
      steps {
        sh 'docker system prune -a -f'
      }
    }

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

    stage("Build image for production environment") {
      steps {
        sh 'docker build -f Dockerfile.prod -t $DOCKERHUB_CREDENTIALS_USR/sample-web . --no-cache'
      }
    }

    stage("Login Docker") {
      steps {
        sh 'echo $DOCKERHUB_CREDENTIALS_PSW | docker login -u $DOCKERHUB_CREDENTIALS_USR --password-stdin'
      }
    }

    stage("Push image") {
      steps {
        sh 'docker push $DOCKERHUB_CREDENTIALS_USR/sample-web'
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
