#!/bin/bash
# Docker entrypoint script for Claude-Flake MVP

set -euo pipefail

# Error handling function
handle_error() {
    echo "❌ Error occurred in entrypoint script at line $1"
    exit 1
}

trap 'handle_error $LINENO' ERR

echo "🚀 Starting Claude-Flake Docker environment..."
echo "📁 Workspace: /workspace"
echo "🏠 Home: $HOME"
echo "👤 User: $(whoami)"

# Check for persistent volumes
echo "🔍 Checking persistent volumes..."
if [ -d "$HOME/.config" ] && [ -w "$HOME/.config" ]; then
    echo "✅ Configuration persistence: $HOME/.config"
else
    echo "⚠️  Configuration not persistent - mount with: -v claude-config:/home/claude/.config"
fi

if [ -d "$HOME/.cache/nix" ] && [ -w "$HOME/.cache/nix" ]; then
    echo "✅ Nix cache persistence: $HOME/.cache/nix"
else
    echo "⚠️  Nix cache not persistent - mount with: -v claude-cache:/home/claude/.cache/nix"
fi

# Source Claude-Flake configuration if available
if [ -f "$HOME/.config/claude-flake/loader.sh" ]; then
    echo "✅ Loading Claude-Flake configuration..."
    # shellcheck source=/dev/null
    source "$HOME/.config/claude-flake/loader.sh"
    echo "✅ Configuration loaded successfully"
else
    echo "⚠️  Claude-Flake configuration not found at $HOME/.config/claude-flake/loader.sh"
    echo "💡 This might be the first run - configuration will be available after setup"
    echo "🔧 You can initialize manually with: nix run github:smithclay/claude-flake"
fi

# Check if workspace is mounted and accessible
if [ -d "/workspace" ]; then
    if [ "$(ls -A /workspace 2>/dev/null)" ]; then
        echo "📂 Workspace mounted with content"
        echo "📋 Contents: $(find /workspace -maxdepth 1 | wc -l) items"
    else
        echo "📂 Empty workspace - mount your project with: docker run -v \$(pwd):/workspace"
    fi
else
    echo "❌ Workspace directory not found - this is unexpected"
    exit 1
fi

# Show available commands if Claude-Flake is loaded
if command -v claude >/dev/null 2>&1; then
    echo "🎯 Claude-Flake commands available: claude, task-master, tm"
fi

# Execute the command passed to docker run, or start bash
echo "🔄 Starting command: $*"
exec "$@"