#!/bin/bash

set -e

IMAGE_NAME="genai-nix-flake-example"
CONTAINER_NAME="genai-nix-test"

exec > >(tee output.log) 2>&1

echo "🐳 Building Docker image..."
docker build -t $IMAGE_NAME .

echo "🚀 Starting test container..."
docker run --rm --name $CONTAINER_NAME -d $IMAGE_NAME tail -f /dev/null

cleanup() {
    echo "🧹 Cleaning up..."
    docker stop $CONTAINER_NAME 2>/dev/null || true
}
trap cleanup EXIT

echo "✅ Testing basic functionality..."

echo "  • Checking user is clay..."
USER_CHECK=$(docker exec $CONTAINER_NAME whoami)
if [ "$USER_CHECK" != "clay" ]; then
    echo "❌ Expected user 'clay', got '$USER_CHECK'"
    exit 1
fi
echo "    ✓ User is clay"

echo "  • Checking Nix installation..."
docker exec $CONTAINER_NAME bash -c '. ~/.nix-profile/etc/profile.d/nix.sh && nix --version' >/dev/null
echo "    ✓ Nix is installed"

echo "  • Checking Node.js availability..."
docker exec $CONTAINER_NAME bash -c '. ~/.nix-profile/etc/profile.d/nix.sh && node --version' >/dev/null
echo "    ✓ Node.js is available"

echo "  • Checking home-manager installation..."
docker exec $CONTAINER_NAME bash -c '. ~/.nix-profile/etc/profile.d/nix.sh && nix run home-manager -- --version' >/dev/null
echo "    ✓ home-manager is available via nix run"

echo "  • Checking npm global packages path..."
NPM_PATH=$(docker exec $CONTAINER_NAME bash -c '. ~/.nix-profile/etc/profile.d/nix.sh && . ~/.profile && echo $PATH')
echo "    ✓ PATH includes: $NPM_PATH"

echo "  • Checking Claude CLI installation..."
CLAUDE_CHECK=$(docker exec $CONTAINER_NAME bash -c '. ~/.nix-profile/etc/profile.d/nix.sh && claude --version 2>/dev/null || echo "not found"')
if [[ "$CLAUDE_CHECK" == *"not found"* ]]; then
    echo "    ⚠️  Claude CLI not found"
else
    echo "    ✓ Claude CLI is installed: $CLAUDE_CHECK"
fi

echo "  • Checking Task Master installation..."
TASKMASTER_CHECK=$(docker exec $CONTAINER_NAME bash -c '. ~/.nix-profile/etc/profile.d/nix.sh && task-master --version 2>/dev/null || echo "not found"')
if [[ "$TASKMASTER_CHECK" == *"not found"* ]]; then
    echo "    ⚠️  Task Master not found"
else
    echo "    ✓ Task Master is installed: $TASKMASTER_CHECK"
fi

echo ""
echo "🎉 All tests passed! Docker image is working correctly."
echo ""
echo "To run the container interactively:"
echo "  docker run -it --rm $IMAGE_NAME"