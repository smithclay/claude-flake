#!/usr/bin/env bash
# Update VERSION file with latest git tag and commit hash

set -euo pipefail

# Get the latest git tag
LATEST_TAG=$(git describe --tags --abbrev=0 2>/dev/null || echo "0.0.0")

# Get the current commit hash (short version)
COMMIT_HASH=$(git rev-parse --short HEAD)

# Get commit count since last tag for dev versioning
COMMIT_COUNT=$(git rev-list "${LATEST_TAG}..HEAD" --count 2>/dev/null || echo "0")

# Construct version string
if [[ "$COMMIT_COUNT" -eq 0 ]]; then
    # We're exactly on a tag
    VERSION="${LATEST_TAG}"
else
    # We're ahead of the last tag, add commit info
    VERSION="${LATEST_TAG}+${COMMIT_COUNT}.${COMMIT_HASH}"
fi

# Update the VERSION file
echo "$VERSION" > VERSION

echo "Updated VERSION to: $VERSION"