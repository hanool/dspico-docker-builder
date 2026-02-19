#!/usr/bin/env bash
set -euo pipefail

IMAGE_NAME="loader"
DOCKERFILE="loader_launcher.dockerfile"
CONTAINER_NAME="loader_extract"
OUTPUT_DIR="out"

if ! docker image inspect "$IMAGE_NAME" >/dev/null 2>&1; then
  docker build -f "$DOCKERFILE" -t "$IMAGE_NAME" .
fi

if docker container inspect "$CONTAINER_NAME" >/dev/null 2>&1; then
  docker rm -f "$CONTAINER_NAME" >/dev/null
fi

mkdir -p "$OUTPUT_DIR"
docker create --name "$CONTAINER_NAME" "$IMAGE_NAME" placeholder >/dev/null
docker cp "$CONTAINER_NAME:/build/." "./$OUTPUT_DIR/"
docker rm "$CONTAINER_NAME" >/dev/null
