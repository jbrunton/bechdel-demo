#!/bin/bash
set -e

export COMPOSE_FILE=docker-compose.yml

# Verify the tag appears on master. Grep returns with an exit code of 1 if it doesn't find anything.
git branch --contains "tags/$TAG" | grep master

echo "$DOCKER_ACCESS_TOKEN" | docker login -u "$DOCKER_USERNAME" --password-stdin

export DEPLOYMENT_FILE=deployments/docker-compose.${TAG}.yml
docker-compose -v
docker-compose pull
docker-compose config --resolve-image-digests > $DEPLOYMENT_FILE

echo "Generated deployment file $DEPLOYMENT_FILE:"
cat $DEPLOYMENT_FILE

git config --global user.email "jbrunton-ci-minion@outlook.com"
git config --global user.name "jbrunton-ci-minion"
git add $DEPLOYMENT_FILE
git commit -m "Generated deployment file for $TAG"

git status

echo GITHUB_SHA=$GITHUB_SHA
echo GITHUB_REF=$GITHUB_REF
