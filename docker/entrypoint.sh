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

# Setup Claude-Flake if not already configured
if [ ! -f "$HOME/.config/claude-flake/loader.sh" ]; then
    echo "🔧 Setting up Claude-Flake using direct home-manager..."
    if [ -d "$HOME/claude-flake-source" ]; then
        cd "$HOME/claude-flake-source"
        echo "📦 Running: nix run nixpkgs#home-manager -- switch --flake .#claude@linux"
        # Set environment to suppress interactive prompts and pipe yes responses
        export NIX_CONFIG="accept-flake-config = true"
        if yes | nix run nixpkgs#home-manager --accept-flake-config -- switch --flake ".#claude@linux"; then
            echo "✅ Claude-Flake setup complete from local source"
        else
            echo "❌ Local setup failed"
            echo "💡 Manual setup: nix run nixpkgs#home-manager --accept-flake-config -- switch --flake .#claude@linux"
        fi
        cd /workspace
    else
        echo "❌ Local source not found at $HOME/claude-flake-source"
        echo "💡 Manual setup: nix run nixpkgs#home-manager --accept-flake-config -- switch --flake github:smithclay/claude-flake#user@linux"
    fi
fi

# Source Claude-Flake configuration if available
if [ -f "$HOME/.config/claude-flake/loader.sh" ]; then
    echo "✅ Loading Claude-Flake configuration..."
    # shellcheck source=/dev/null
    source "$HOME/.config/claude-flake/loader.sh"
    echo "✅ Configuration loaded successfully"
else
    echo "⚠️  Claude-Flake configuration still not found"
    echo "💡 Manual setup: cd ~/claude-flake-source && USER=$USER nix run .#default --accept-flake-config"
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
    echo "  Available commands: $(ls $HOME/.nix-profile/bin | head -5 | tr '\n' ' ')..."
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