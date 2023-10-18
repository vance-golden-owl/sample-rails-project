pipeline {
  agent any
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

    stage("Building") {
      steps {
        sh 'docker compose -f docker-compose.test.yml up -d'
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
  }

  post {
    always {
      sh 'docker compose -f docker-compose.test.yml down --remove-orphans -v'
    }
  }
}