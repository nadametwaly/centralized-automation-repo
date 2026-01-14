#!/bin/sh
set -e

REGISTRY="$INPUT_REGISTRY"
USERNAME="$INPUT_USERNAME"
PASSWORD="$INPUT_PASSWORD"
IMAGE_NAME="$INPUT_IMAGE_NAME"
TAG="$INPUT_TAG"
SHA=$(echo "$GITHUB_SHA" | cut -c1-7)

FULL_IMAGE="$REGISTRY/$USERNAME/$IMAGE_NAME"
SHA_TAG="$FULL_IMAGE:$SHA"
LATEST_TAG="$FULL_IMAGE:$TAG"

echo "🔐 Logging into $REGISTRY..."
echo "$PASSWORD" | docker login "$REGISTRY" -u "$USERNAME" --password-stdin

echo "🐳 Building Docker image..."
docker build -t "$LATEST_TAG" -t "$SHA_TAG" .

echo "📤 Pushing images..."
docker push "$LATEST_TAG"
docker push "$SHA_TAG"

DIGEST=$(docker inspect --format='{{index .RepoDigests 0}}' "$SHA_TAG" | cut -d'@' -f2)

echo "image_name=$SHA_TAG" >> $GITHUB_OUTPUT
echo "image_digest=$DIGEST" >> $GITHUB_OUTPUT
echo "push_status=success" >> $GITHUB_OUTPUT

echo "✅ Image pushed: $SHA_TAG"
