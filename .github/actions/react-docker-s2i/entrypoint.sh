#!/bin/sh
set -e

APP_PATH="$GITHUB_WORKSPACE/frontend"
IMAGE_NAME="$INPUT_REGISTRY/$INPUT_USERNAME/$INPUT_IMAGE_NAME"
SHA_TAG="$IMAGE_NAME:$(echo $GITHUB_SHA | cut -c1-7)"
LATEST_TAG="$IMAGE_NAME:$INPUT_TAG"

echo "$INPUT_PASSWORD" | docker login "$INPUT_REGISTRY" -u "$INPUT_USERNAME" --password-stdin

docker build -t "$LATEST_TAG" -t "$SHA_TAG" "$APP_PATH"
docker push "$LATEST_TAG"
docker push "$SHA_TAG"

DIGEST=$(docker inspect --format='{{index .RepoDigests 0}}' "$SHA_TAG" | cut -d'@' -f2)

echo "image_name=$SHA_TAG" >> $GITHUB_OUTPUT
echo "image_digest=$DIGEST" >> $GITHUB_OUTPUT
echo "push_status=success" >> $GITHUB_OUTPUT
