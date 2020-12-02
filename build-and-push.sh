#!/bin/sh

# This scripts builds the image and pushes it to its Docker Hub repository

REPO=smarthelios/vault-secrets-processor
TAG=latest

docker build -t ${REPO} .

docker tag ${REPO}:${TAG} ${REPO}:${TAG}

docker push ${REPO}:${TAG}