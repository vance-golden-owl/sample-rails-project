#!/bin/bash

cd ./sample-rails-project

echo "Pulling new code from github..."
env -i git pull origin main
env -i git checkout main

echo "Deploying docker image"

docker-compose -f docker-compose.prod.yml pull
docker-compose -f docker-compose.prod.yml up -d

echo "Completed"
