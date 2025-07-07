# Docker Example

This directory contains a simple Docker setup that demonstrates using the claude-flake with Ubuntu.

## Files

- `Dockerfile` - Ubuntu 22.04 image with Nix and claude-taskmaster flake
- `test-docker.sh` - Test script to verify the Docker image works correctly

## Usage

### Build and Test

```bash
cd examples
./test-docker.sh
```

### Run Interactively

```bash
cd examples
docker build -t claude-flake-example .
docker run -it --rm claude-flake-example
```

## What's Included

The Docker image includes:
- Ubuntu 22.04 base
- User `clay` with sudo access
- Nix package manager with flakes enabled
- Base development environment (via home-manager `base` configuration)
- Claude CLI and Task Master (via home-manager `claude-taskmaster` configuration)
- Claude-flake loader integrated into shell configuration

## Notes

- This is an integration test for the home-manager configurations
- Claude CLI requires API key configuration to be fully functional
- Task Master requires Claude CLI to be properly configured
- Tests both `base` and `claude-taskmaster` home-manager flake configurations
- The loader is automatically integrated into `.bashrc` and `.profile` for immediate availability