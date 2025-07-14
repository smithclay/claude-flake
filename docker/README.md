# Docker MVP - Phase 2A

> **Phase 2A**: Simple single-stage Docker container for Claude-Flake with basic functionality.

This Docker implementation provides a containerized environment for Claude-Flake, making it easy to run Claude Code without local installation.

## Quick Start

### Build the Image
```bash
# Build from the project root directory
docker build -t claude-flake-mvp -f docker/Dockerfile .

# Or build with a specific tag
docker build -t claude-flake:latest -f docker/Dockerfile .
```

### Run with Volume Mounting
```bash
# Basic usage - mount current directory as workspace
docker run -it -v $(pwd):/workspace claude-flake-mvp

# With Nix cache persistence (recommended)
docker run -it \
  -v $(pwd):/workspace \
  -v claude-cache:/home/claude/.cache/nix \
  claude-flake-mvp

# With credentials for Claude CLI
docker run -it \
  -v $(pwd):/workspace \
  -v claude-cache:/home/claude/.cache/nix \
  -v ~/.claude/.credentials.json:/home/claude/.claude/.credentials.json:ro \
  claude-flake-mvp

# Run in background for long-running tasks
docker run -d \
  -v $(pwd):/workspace \
  -v claude-cache:/home/claude/.cache/nix \
  --name claude-workspace \
  claude-flake-mvp
```

### What's Included

- **Nix Environment**: Nix package manager with flakes enabled
- **Claude-Flake Configuration**: Home-manager based setup
- **Claude CLI**: Latest Claude Code CLI
- **Enhanced Tools**: bat, eza, fzf, ripgrep, and more
- **Workspace**: Dedicated `/workspace` directory for volume mounting
- **Security**: Non-root user (`claude`) for secure operation
- **Shell Integration**: Pre-configured aliases and environment

### Testing the Container

```bash
# Test basic functionality
docker run -it claude-flake-mvp bash -c "echo 'Testing Claude-Flake container...'"

# Test with workspace mounting
mkdir test-workspace
echo "Hello from host" > test-workspace/test.txt
docker run -it -v $(pwd)/test-workspace:/workspace -v claude-cache:/home/claude/.cache/nix claude-flake-mvp bash -c "ls -la /workspace && cat /workspace/test.txt"

# Test enhanced commands
docker run -it -v $(pwd):/workspace -v claude-cache:/home/claude/.cache/nix claude-flake-mvp bash -c "ll /workspace"

# Test Claude CLI availability
docker run -it -v claude-cache:/home/claude/.cache/nix claude-flake-mvp bash -c "claude --help || echo 'Claude CLI not yet available'"


# Interactive session with workspace
docker run -it -v $(pwd):/workspace -v claude-cache:/home/claude/.cache/nix claude-flake-mvp
```

### Expected Behavior

When running the container:
1. **Initialization**: Entrypoint script starts and shows status messages
2. **Configuration Loading**: Claude-Flake loader is sourced if available
3. **Workspace Detection**: Workspace mounting is detected and reported
4. **Environment Setup**: Shell starts with Claude-Flake environment
5. **Command Availability**: Enhanced commands (ll, cat, grep) are available
6. **Error Handling**: Graceful handling of setup issues with helpful messages

### Current Limitations (Phase 2B)

- **Image Size**: Single-stage build results in larger image size
- **Optimization**: Basic functionality only, no performance optimization
- **Manual Setup**: Manual volume mounting required for workspace
- **First Run**: Claude-Flake setup may not complete on first container start
- **API Keys**: Environment variables needed for Claude CLI functionality

### New Persistence Features ✅

- **Nix Cache Persistence**: Mount `-v claude-cache:/home/claude/.cache/nix` for faster rebuilds
- **Credentials Mounting**: Mount `-v ~/.claude/.credentials.json:/home/claude/.claude/.credentials.json:ro` for Claude CLI access
- **Automatic Detection**: Entrypoint script detects and reports volume mounting status

## Troubleshooting

### Common Issues

```bash
# If Claude CLI is not available
docker exec -it <container-id> nix run nixpkgs#home-manager --accept-flake-config -- switch --flake github:smithclay/claude-flake#user@linux

# If permissions are wrong
docker run -it -v $(pwd):/workspace -v claude-cache:/home/claude/.cache/nix -u $(id -u):$(id -g) claude-flake-mvp

# If workspace is not mounted
docker run -it -v $(pwd):/workspace -v claude-cache:/home/claude/.cache/nix claude-flake-mvp ls -la /workspace

# Check volume mounting status
docker run -it -v $(pwd):/workspace -v claude-cache:/home/claude/.cache/nix claude-flake-mvp bash -c "ls -la /home/claude/.cache/nix"

# Reset Nix cache
docker volume rm claude-cache
```

### Persistence Management

```bash
# List persistent volumes
docker volume ls | grep claude

# Inspect volume details
docker volume inspect claude-cache

# Backup Nix cache
docker run --rm -v claude-cache:/source -v $(pwd):/backup alpine tar czf /backup/claude-cache.tar.gz -C /source .

# Restore Nix cache
docker run --rm -v claude-cache:/target -v $(pwd):/backup alpine tar xzf /backup/claude-cache.tar.gz -C /target
```

### Debug Mode

```bash
# Run with debug output
docker run -it -v $(pwd):/workspace -v claude-cache:/home/claude/.cache/nix claude-flake-mvp bash -x
```

## Phase 2B Completed ✅

- **✅ GitHub Flake Access**: `nix run nixpkgs#home-manager -- switch --flake github:smithclay/claude-flake#user@linux` support
- **✅ Nix Cache Persistence**: Persistent Nix cache across containers
- **✅ Enhanced Docker**: Improved entrypoint with persistence detection
- **✅ Clear Documentation**: Volume mounting and persistence management guides

## Roadmap (Phase 3A)

- **Multi-stage Docker**: Optimized builds with smaller images
- **Automatic Workspace Detection**: Smart project detection
- **Pre-built Images**: Published images on container registry
- **API Key Management**: Secure API key handling
- **Performance Optimization**: Faster startup and rebuild times