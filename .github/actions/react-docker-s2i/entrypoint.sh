#!/bin/sh
set -e  # Exit immediately if a command fails
set -o pipefail  # Fail if any command in a pipe fails

# Paths & Image
APP_PATH="${GITHUB_WORKSPACE}/frontend"
IMAGE_NAME="${INPUT_REGISTRY}/${INPUT_USERNAME}/${INPUT_IMAGE_NAME}"
SHA_TAG="${IMAGE_NAME}:$(echo "${GITHUB_SHA}" | cut -c1-7)"
LATEST_TAG="${IMAGE_NAME}:${INPUT_TAG:-latest}"  # fallback to 'latest' if INPUT_TAG is empty

# Login to Docker registry
echo "🔐 Logging into $INPUT_REGISTRY as $INPUT_USERNAME..."
echo "${INPUT_PASSWORD}" | docker login "$INPUT_REGISTRY" -u "$INPUT_USERNAME" --password-stdin

# Build and tag Docker image
echo "🐳 Building Docker image..."
docker build -t "$LATEST_TAG" -t "$SHA_TAG" "$APP_PATH"

# Push images
echo "📤 Pushing Docker images..."
docker push "$LATEST_TAG"
docker push "$SHA_TAG"

# Get image digest
DIGEST=$(docker inspect --format='{{index .RepoDigests 0}}' "$SHA_TAG" | cut -d'@' -f2)

# Set GitHub Actions outputs
echo "image_name=$SHA_TAG" >> "$GITHUB_OUTPUT"
echo "image_digest=$DIGEST" >> "$GITHUB_OUTPUT"
echo "push_status=success" >> "$GITHUB_OUTPUT"

echo "✅ Docker image pushed successfully: $SHA_TAG"
