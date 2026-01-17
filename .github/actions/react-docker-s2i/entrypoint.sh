#!/bin/bash
set -e

echo "Login to registry"
echo "$INPUT_PASSWORD" | docker login "$INPUT_REGISTRY" \
  -u "$INPUT_USERNAME" --password-stdin

IMAGE="$INPUT_REGISTRY/$INPUT_IMAGE_NAME:$INPUT_TAG"

WORKSPACE="$GITHUB_WORKSPACE"

echo "Workspace content check:"
ls -la "$WORKSPACE"

echo "Build Docker image"
docker build \
  -t "$IMAGE" \
  -f "$GITHUB_ACTION_PATH/Dockerfile.react" \
  "$WORKSPACE/React-Frontend"

echo "Push Docker image"
docker push "$IMAGE"

echo "image_name=$IMAGE" >> $GITHUB_OUTPUT