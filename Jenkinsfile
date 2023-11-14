void setBuildStatus(String message, String state) {
  step([
      $class: "GitHubCommitStatusSetter",
      reposSource: [$class: "ManuallyEnteredRepositorySource", url: "https://github.com/vance-golden-owl/sample-rails-project.git"],
      contextSource: [$class: "ManuallyEnteredCommitContextSource", context: "ci/jenkins/build-status"],
      errorHandlers: [[$class: "ChangingBuildStatusErrorHandler", result: "UNSTABLE"]],
      statusResultSource: [ $class: "ConditionalStatusResultSource", results: [[$class: "AnyBuildResult", message: message, state: state]] ]
  ]);
}

pipeline {
  agent any

  stages {
    stage("Build") {
      steps {
        setBuildStatus("Build pending", "PENDING");
        sh 'docker compose -f docker-compose.test.yml up -d --build'
      }
    }

    stage("Lint") {
      steps {
        sh 'docker exec sample-rails-project-web-1 bundle exec rubocop'
      }
    }

    stage("Test") {
      steps {
        sh 'docker exec sample-rails-project-web-1 bundle exec rspec'
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
                ssh -o StrictHostKeyChecking=no ec2-user@ec2-18-142-229-1.ap-southeast-1.compute.amazonaws.com 'docker-compose -f sample-rails-project/docker-compose.yml pull'
                ssh -o StrictHostKeyChecking=no ec2-user@ec2-18-142-229-1.ap-southeast-1.compute.amazonaws.com 'docker-compose -f sample-rails-project/docker-compose.yml up -d'
              '''
            }
          }
        }
      }
    }
  }

  post {
    success {
      setBuildStatus("Build succeeded", "SUCCESS");
    }

    failure {
      setBuildStatus("Build failed", "FAILURE");
    }

    always {
      sh 'docker compose -f docker-compose.test.yml down --remove-orphans -v'
      sh 'docker logout'
    }
  }
}
