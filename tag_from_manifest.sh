#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage: ./tag_from_manifest.sh [--push]

Creates a git tag v<version_number> based on manifest.json.

Options:
  --push    Push the tag to origin after creating it.
USAGE
}

PUSH=false
if [ "${1-}" = "--push" ]; then
  PUSH=true
elif [ "${1-}" != "" ]; then
  usage >&2
  exit 2
fi

if ! command -v jq >/dev/null 2>&1; then
  echo "jq is required but not found. Install jq and try again." >&2
  exit 1
fi

if [ ! -f manifest.json ]; then
  echo "manifest.json not found in current directory." >&2
  exit 1
fi

VERSION=$(jq -r '.version_number' manifest.json)
if [ -z "$VERSION" ] || [ "$VERSION" = "null" ]; then
  echo "version_number missing in manifest.json" >&2
  exit 1
fi

TAG="v$VERSION"

# Avoid failing if tag already exists
if git rev-parse "$TAG" >/dev/null 2>&1; then
  echo "Tag $TAG already exists."
  exit 0
fi

git tag "$TAG"

echo "Created tag $TAG."

if [ "$PUSH" = true ]; then
  git push origin "$TAG"
  echo "Pushed tag $TAG to origin."
else
  echo "Push it with: git push origin $TAG"
fi
