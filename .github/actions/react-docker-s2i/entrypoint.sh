#!/bin/sh
set -e

echo "🚀 React S2I Action Started"

# Inputs
REGISTRY="${INPUT_REGISTRY}"
USERNAME="${INPUT_USERNAME}"
PASSWORD="${INPUT_PASSWORD}"
IMAGE_NAME="${INPUT_IMAGE_NAME}"
TAG="${INPUT_TAG:-latest}"

SHA_TAG="${GITHUB_SHA}"

# Validate inputs
if [ -z "$REGISTRY" ] || [ -z "$USERNAME" ] || [ -z "$PASSWORD" ] || [ -z "$IMAGE_NAME" ]; then
  echo "❌ Missing required inputs"
  exit 1
fi

# Validate build output
if [ ! -d "frontend/dist" ]; then
  echo "❌ frontend/dist not found. Did you run npm run build?"
  exit 1
fi

if [ ! -f "frontend/nginx.conf" ]; then
  echo "❌ frontend/nginx.conf not found"
  exit 1
fi

# Login to registry
echo "$PASSWORD" | docker login "$REGISTRY" -u "$USERNAME" --password-stdin

# Prepare build context
echo "📦 Preparing Docker build context..."
BUILD_CTX=$(mktemp -d)

cp -r frontend/dist "$BUILD_CTX/dist"
cp frontend/nginx.conf "$BUILD_CTX/nginx.conf"
cp "$GITHUB_ACTION_PATH/Dockerfile.react" "$BUILD_CTX/Dockerfile"

# Build image
echo "🐳 Building image..."
docker build \
  -t "$REGISTRY/$IMAGE_NAME:$TAG" \
  -t "$REGISTRY/$IMAGE_NAME:$SHA_TAG" \
  "$BUILD_CTX"

# Push image
echo "📤 Pushing image..."
docker push "$REGISTRY/$IMAGE_NAME:$TAG"
docker push "$REGISTRY/$IMAGE_NAME:$SHA_TAG"

# Get image digest
IMAGE_DIGEST=$(docker inspect --format='{{index .RepoDigests 0}}' "$REGISTRY/$IMAGE_NAME:$SHA_TAG")

# Outputs
echo "image_name=$REGISTRY/$IMAGE_NAME:$SHA_TAG" >> "$GITHUB_OUTPUT"
echo "image_digest=$IMAGE_DIGEST" >> "$GITHUB_OUTPUT"
echo "push_status=success" >> "$GITHUB_OUTPUT"

echo "✅ React image pushed successfully"
