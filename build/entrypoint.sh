#!/bin/bash

set -e
set -x

: ${INPUT_REGISTRY:=gcr.io}
: ${INPUT_IMAGE:=$GITHUB_REPOSITORY}
: ${INPUT_ARGS:=} # Default: empty build args
: ${INPUT_TAG:=$GITHUB_SHA}
: ${INPUT_LATEST:=true}
: ${INPUT_PATH:=.}
: ${INPUT_DOCKERFILE:=Dockerfile}

if [ -n "${INPUT_GCLOUD_KEY}" ]; then
  echo "Logging into gcr.io with INPUT_GCLOUD_KEY..."
  echo ${INPUT_GCLOUD_KEY} | base64 --decode --ignore-garbage > /tmp/key.json
  gcloud auth activate-service-account --quiet --key-file /tmp/key.json
  gcloud auth configure-docker --quiet
else
  echo "INPUT_GCLOUD_KEY was empty, not performing auth" 1>&2
fi

docker pull $INPUT_REGISTRY/$INPUT_IMAGE:$INPUT_TAG

docker build $INPUT_ARGS -f $INPUT_DOCKERFILE -t $INPUT_IMAGE:$INPUT_TAG $INPUT_PATH --cache-from $INPUT_REGISTRY/$INPUT_IMAGE:$INPUT_TAG
docker tag $INPUT_IMAGE:$INPUT_TAG $INPUT_REGISTRY/$INPUT_IMAGE:$INPUT_TAG

if [ $INPUT_LATEST = true ]; then
  docker tag $INPUT_IMAGE:$INPUT_TAG $INPUT_REGISTRY/$INPUT_IMAGE:latest
fi
