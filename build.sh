#!/usr/bin/env bash

# Prerequisite
# Make sure you set secret enviroment variables in Travis CI
# DOCKER_USERNAME
# DOCKER_PASSWORD

set -e

image="hasanozgan/yq"

docker build --no-cache -t ${image}:latest .

DOCKER_PUSH="docker buildx build --no-cache --push --platform linux/amd64,linux/arm/v7,linux/arm64/v8,linux/arm/v6,linux/ppc64le,linux/s390x,linux/386" 

# add another tag with git version, with this way, we can check this git image health
VERSION=($(docker run -i --rm ${image}:latest version|awk '{print $NF}'))
echo ${VERSION}

# install crane
curl -LO https://github.com/google/go-containerregistry/releases/download/v0.11.0/go-containerregistry_Linux_x86_64.tar.gz
tar zxvf go-containerregistry_Linux_x86_64.tar.gz
chmod +x crane

if [[ "$CIRCLE_BRANCH" == "master" && "$CIRCLE_PULL_REQUEST" == "" ]]; then
  docker login -u $DOCKER_USERNAME -p $DOCKER_PASSWORD
  docker buildx create --use
  ${DOCKER_PUSH} -t ${image}:v${VERSION} .
  ./crane copy ${image}:v${VERSION} ${image}:latest
  ./crane copy ${image}:v${VERSION} ${image}:${VERSION}
fi

if [[ "$CIRCLE_BRANCH" == "feature/non-root" && "$CIRCLE_PULL_REQUEST" == "" ]]; then
  docker login -u $DOCKER_USERNAME -p $DOCKER_PASSWORD
  ${DOCKER_PUSH} -t ${image}:user .
  ./crane copy ${image}:user ${image}:v${VERSION}-user
  ./crane copy ${image}:user ${image}:${VERSION}-user
fi
