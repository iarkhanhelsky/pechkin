#!/bin/bash
set -e

# Script to build Pechkin Docker image

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Default values
IMAGE_NAME="${IMAGE_NAME:-pechkin}"
IMAGE_TAG="${IMAGE_TAG:-latest}"

echo "Building Pechkin Docker image..."
echo "Image: ${IMAGE_NAME}:${IMAGE_TAG}"
echo "Project root: ${PROJECT_ROOT}"
echo ""

cd "$PROJECT_ROOT"

docker build \
    -f docker/Dockerfile \
    -t "${IMAGE_NAME}:${IMAGE_TAG}" \
    .

echo ""
echo "Build complete!"
echo "Image: ${IMAGE_NAME}:${IMAGE_TAG}"
echo ""
echo "To run the container:"
echo "  docker run -d -p 9292:9292 -v /path/to/config:/var/data/pechkin ${IMAGE_NAME}:${IMAGE_TAG}"
echo ""
echo "Or use docker-compose:"
echo "  cd docker && docker-compose up -d"
