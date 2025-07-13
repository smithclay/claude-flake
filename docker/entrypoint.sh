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

# Check if Claude-Flake was pre-installed during build
if [ -f "$HOME/.config/claude-flake/loader.sh" ]; then
    echo "✅ Claude-Flake was pre-installed during build"
else
    echo "⚠️  Claude-Flake not found - build may have failed"
    echo "💡 Manual setup: cd ~/claude-flake-source && nix run --impure --accept-flake-config .#apps.x86_64-linux.home"
fi

# Source Claude-Flake configuration if available
if [ -f "$HOME/.config/claude-flake/loader.sh" ]; then
    echo "✅ Loading Claude-Flake configuration..."
    # shellcheck source=/dev/null
    source "$HOME/.config/claude-flake/loader.sh"
    echo "✅ Configuration loaded successfully"
else
    echo "⚠️  Claude-Flake configuration still not found"
    echo "💡 Manual setup: cd ~/claude-flake-source && nix run --impure --accept-flake-config .#apps.x86_64-linux.home"
fi

# Ensure home-manager profile is in PATH
if [ -f "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh" ]; then
    echo "🔄 Loading home-manager session variables..."
    # shellcheck source=/dev/null
    set +u  # Temporarily disable unbound variable checking
    source "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh" 2>/dev/null || echo "Warning: Session variables load had minor issues"
    set -u  # Re-enable unbound variable checking
fi

# Add home-manager profile and npm global to PATH if not already there
export PATH="$HOME/.npm-global/bin:$HOME/.nix-profile/bin:$PATH"

# Note: .bashrc is managed by home-manager, not modified directly here

# Show PATH and available commands for debugging
echo "🚿 Debug info:"
echo "  PATH: $PATH"
echo "  Home-manager profile exists: $([ -d "$HOME/.nix-profile" ] && echo "Yes" || echo "No")"
if [ -d "$HOME/.nix-profile/bin" ]; then
    echo "  Available commands: $(find "$HOME/.nix-profile/bin" -maxdepth 1 -type f -executable | head -5 | xargs -I {} basename {} | tr '\n' ' ')..."
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
    echo "💡 Run 'cf-help' to see all available aliases"
fi

# Update ~/.claude.json with onboarding properties
echo "🔧 Setting up Claude CLI configuration..."
mkdir -p "$HOME/.claude"
CLAUDE_VERSION=$(claude --version 2>/dev/null | head -1 | cut -d' ' -f2 || echo "unknown")

# Check if ~/.claude.json exists, create if not
if [ ! -f "$HOME/.claude.json" ]; then
    echo "{}" > "$HOME/.claude.json"
fi

# Use jq to add/update onboarding properties
jq --arg version "$CLAUDE_VERSION" '. + {
  "hasCompletedOnboarding": true,
  "lastCompletedOnboarding": $version
}' "$HOME/.claude.json" > "$HOME/.claude.json.tmp" && mv "$HOME/.claude.json.tmp" "$HOME/.claude.json"

echo "✅ Claude CLI configuration updated with version: $CLAUDE_VERSION"

# Execute the command passed to docker run, or start bash
echo "🔄 Starting command: $*"
exec "$@"