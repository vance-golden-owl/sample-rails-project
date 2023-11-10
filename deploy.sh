#!/bin/bash

echo "Pulling new code from github..."

git pull origin main
git checkout main

echo "Deploying docker image"

docker-compose -f docker-compose.prod.yml pull
docker-compose -f docker-compose.prod.yml up -d

echo "Completed"
