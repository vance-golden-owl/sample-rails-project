void setBuildStatus(String context, String message, String state) {
  step([
      $class: "GitHubCommitStatusSetter",
      reposSource: [$class: "ManuallyEnteredRepositorySource", url: "https://github.com/vance-golden-owl/sample-rails-project.git"],
      contextSource: [$class: "ManuallyEnteredCommitContextSource", context: context],
      errorHandlers: [[$class: "ChangingBuildStatusErrorHandler", result: "UNSTABLE"]],
      statusResultSource: [ $class: "ConditionalStatusResultSource", results: [[$class: "AnyBuildResult", message: message, state: state]] ]
  ]);
}

pipeline {
  agent any

  stages {
    stage("Build") {
      steps {
        sh 'docker compose -f docker-compose.test.yml up -d --build'
      }
    }

    stage("Lint") {
      steps {
        sh 'docker exec sample-rails-project-web-1 bundle exec rubocop'
      }
      post {
        success {
          setBuildStatus("Rubocop", "Lint passed", "SUCCESS");
        }
        failure {
          setBuildStatus("Rubocop", "Lint failed", "FAILURE");
        }
      }
    }

    stage("Test") {
      steps {
        sh 'docker exec sample-rails-project-web-1 bundle exec rspec'
      }
      post {
        success {
          setBuildStatus("Rspec", "Test passed", "SUCCESS");
        }
        failure {
          setBuildStatus("Rspec", "Test failed", "FAILURE");
        }
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

        stage("Run bash script") {
          steps {
            sshagent(credentials: ['010a2972-8913-47dd-8341-2b6ecd2d2b64']) {
              sh '''
                ssh -o StrictHostKeyChecking=no ec2-user@ec2-3-1-194-185.ap-southeast-1.compute.amazonaws.com 'docker-compose -f sample-rails-project/docker-compose.yml pull'
                ssh -o StrictHostKeyChecking=no ec2-user@ec2-3-1-194-185.ap-southeast-1.compute.amazonaws.com 'docker-compose -f sample-rails-project/docker-compose.yml up -d'
              '''
            }
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
