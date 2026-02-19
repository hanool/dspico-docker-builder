#!/usr/bin/env bash
set -euo pipefail

IMAGE_NAME="dspico-builder"
DOCKERFILE="loader_launcher.dockerfile"
OUTPUT_DIR="out"
ASSETS_DIR="assets"

MODE="${1:-}"
if [[ -n "$MODE" ]]; then
  shift
fi

if [[ -z "$MODE" ]]; then
  if [[ ! -t 0 ]]; then
    echo "No mode provided and no interactive terminal available" >&2
    echo "Usage: ./build.sh [loader-launcher|firmware|all] [--wrfuxxed]" >&2
    exit 1
  fi

  echo "Select build mode:"
  echo "  1) loader-launcher"
  echo "  2) firmware"
  echo "  3) all"

  while true; do
    read -r -p "Enter choice [1-3]: " CHOICE
    case "$CHOICE" in
      1)
        MODE="loader-launcher"
        break
        ;;
      2)
        MODE="firmware"
        break
        ;;
      3)
        MODE="all"
        break
        ;;
      *)
        echo "Invalid choice: $CHOICE. Please enter 1, 2, or 3." >&2
        ;;
    esac
  done
fi

ENABLE_WRFUXXED=0
while [[ $# -gt 0 ]]; do
  case "$1" in
    --wrfuxxed)
      ENABLE_WRFUXXED=1
      ;;
    *)
      echo "Unknown argument: $1" >&2
      exit 1
      ;;
  esac
  shift
done

case "$MODE" in
  loader-launcher|firmware|all)
    ;;
  *)
    echo "Unknown mode: $MODE" >&2
    echo "Usage: ./build.sh [loader-launcher|firmware|all] [--wrfuxxed]" >&2
    exit 1
    ;;
esac

if [[ "$ENABLE_WRFUXXED" -eq 1 && "$MODE" == "loader-launcher" ]]; then
  echo "--wrfuxxed can only be used with firmware or all mode" >&2
  exit 1
fi

docker build -f "$DOCKERFILE" -t "$IMAGE_NAME" .

mkdir -p "$ASSETS_DIR"

rm -rf "$OUTPUT_DIR"
mkdir -p "$OUTPUT_DIR"

CONTAINER_NAME="dspico_extract_$(date +%s%N)_$$"

cleanup() {
  docker rm -f "$CONTAINER_NAME" >/dev/null 2>&1 || true
}
trap cleanup EXIT

CONTAINER_ARGS=("$MODE")
if [[ "$ENABLE_WRFUXXED" -eq 1 ]]; then
  CONTAINER_ARGS+=("--wrfuxxed")
fi

docker create \
  --name "$CONTAINER_NAME" \
  -v "$(pwd)/$ASSETS_DIR:/assets:ro" \
  "$IMAGE_NAME" \
  "${CONTAINER_ARGS[@]}" \
  >/dev/null

docker start -a "$CONTAINER_NAME"
docker cp "$CONTAINER_NAME:/out/." "./$OUTPUT_DIR/"
