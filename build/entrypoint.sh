#!/bin/bash

set -e

: ${INPUT_REGISTRY:=gcr.io}
: ${INPUT_IMAGE:=$GITHUB_REPOSITORY}
: ${INPUT_ARGS:=} # Default: empty build args
: ${INPUT_TAG:=$GITHUB_SHA}
: ${INPUT_LATEST:=true}

docker build $INPUT_ARGS -t $INPUT_IMAGE:$INPUT_TAG .
docker tag $INPUT_IMAGE:$INPUT_TAG $INPUT_REGISTRY/$INPUT_IMAGE:$INPUT_TAG

if [ $INPUT_LATEST = true ]; then
  docker tag $INPUT_IMAGE:$INPUT_TAG $INPUT_REGISTRY/$INPUT_IMAGE:latest
fi
