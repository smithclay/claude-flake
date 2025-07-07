# claude-flake

[![CI](https://github.com/smithclay/claude-flake/actions/workflows/ci.yml/badge.svg)](https://github.com/smithclay/claude-flake/actions/workflows/ci.yml)
[![NixOS](https://img.shields.io/badge/NixOS-5277C3?style=flat&logo=nixos&logoColor=white)](https://nixos.org)
[![Flakes](https://img.shields.io/badge/Nix-Flakes-blue)](https://nixos.wiki/wiki/Flakes)

Nix flake providing consistent Claude Code configuration and development environments across machines.

## 🙏 Credits

This project was inspired by and builds upon the excellent work at [Veraticus/nix-config](https://github.com/Veraticus/nix-config/tree/main/home-manager/claude-code). Thank you for pioneering Claude Code configuration management with Nix!

## 🚀 Quick Start - Just Claude Code + Task Master

Want just Claude Code and Task Master with validated community configuration?

First, install Nix and enable flakes:
```bash
# Install Nix
curl -L https://install.determinate.systems/nix | sh -s -- install

# Enable flakes (restart shell after this)
echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf
```

Then install the configuration:
```bash
nix run home-manager -- switch --flake github:smithclay/claude-flake#claude-taskmaster
```

This installs:
- Claude Code with community-validated settings
- Task Master for AI-powered project management
- Optimized hooks and commands from the Claude Code community
- NPM configuration for global packages
- Claude-flake loader at `~/.config/claude-flake/loader.sh`

**Important**: Add the loader to your shell configuration:
```bash
# For bash users
echo '[[ -r ~/.config/claude-flake/loader.sh ]] && source ~/.config/claude-flake/loader.sh' >> ~/.bashrc

# For zsh users
echo '[[ -r ~/.config/claude-flake/loader.sh ]] && source ~/.config/claude-flake/loader.sh' >> ~/.zshrc
```

## Opinionated Workflow

This packages MCPs, commands, and hooks that have been validated by the wider Claude Code community. The workflow is quickly evolving, but represents current best practices for productive Claude development.

**Hooks** run automatically after Claude modifies files to enforce quality standards. **Commands** are custom `/slash` commands you can use in Claude conversations to trigger specific workflows.

### MCPs (Model Context Protocols)
- **[task-master](https://www.task-master.dev/)** - AI-powered project management that breaks down complex projects into manageable tasks, eliminates context overload, and keeps Claude focused on implementation rather than planning (via task-master-ai npm package)

### Hooks
- **smart-lint.sh** - Intelligent project-aware code quality checks (Go, Python, JavaScript/TypeScript, Rust, Nix)
- **ntfy-notifier.sh** - Push notifications via ntfy service for Claude Code events

### Commands
- **check.md** - Verify code quality, run tests, ensure production readiness (zero-tolerance for issues)
- **next.md** - Execute production-quality implementation with Research → Plan → Implement workflow
- **prompt.md** - Synthesize complete prompts by combining templates with user arguments

PRs welcome to improve the configuration based on community feedback.

## Prerequisites

**Supported platforms:** Linux, macOS, and WSL (Windows Subsystem for Linux)

You need Nix installed with flakes enabled. If you don't have Nix:

1. **Install Nix**: Follow the [official installer](https://nixos.org/download.html)
2. **Enable flakes**: Add experimental features to your config
   ```bash
   echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf
   ```
3. **Restart your shell** to pick up the new configuration

That's it. No need to install anything else - the flake handles all dependencies.

## Development Environments (Optional)

These provide pre-configured project shells with language tooling and Claude integration - useful for starting new projects or working in temporary environments.

```bash
# Python development environment
nix develop github:smithclay/claude-flake#pythonShell

# Rust development environment
nix develop github:smithclay/claude-flake#rustShell
```

Both environments include:
- Language tooling (formatters, linters, etc.)
- Modern CLI tools (bat, eza, fzf, ripgrep)
- Claude Code configuration
- Task Master integration

## Workflow: Writing Code with Claude

### 1. Start Your Project
```bash
# Navigate to your project directory first
cd /path/to/your/project

# For Python projects
nix develop github:smithclay/claude-flake#pythonShell

# For Rust projects  
nix develop github:smithclay/claude-flake#rustShell
```

### 2. Use Claude Code Naturally
- **Claude Code + Task Master** are already configured and ready
- **All language tools** (formatters, linters, testing) work out of the box
- **Modern CLI tools** (bat, eza, fzf, ripgrep) enhance your workflow
- **Consistent environment** across all your machines

### 3. Write Code
- Use your normal editor/IDE workflow
- Claude Code provides AI assistance with full context
- Task Master helps manage complex projects
- All quality tools run automatically via hooks


## What's Included

| Component | Python Shell | Rust Shell | Base Config | Claude Config |
|-----------|-------------|------------|-------------|---------------|
| **Language Tools** | Python 3, pip, poetry, black, ruff, pytest | rustc, cargo, clippy, rust-analyzer | ❌ | ❌ |
| **Claude Code** | ✅ | ✅ | ❌ | ✅ |
| **Task Master** | ✅ | ✅ | ❌ | ✅ |
| **Modern CLI** | bat, eza, fzf, ripgrep | bat, eza, fzf, ripgrep | ✅ | ❌ |
| **Shell Setup** | Basic | Basic | Full (zsh, oh-my-zsh) | Basic |
| **Dev Tools** | Node.js 22 | pkg-config, openssl | git, gh, neovim, tmux | Node.js 22 |

## System Configuration (Optional)

**Base development setup (Optional)** (no Claude dependencies):
```bash
nix run home-manager -- switch --flake github:smithclay/claude-flake#base
```

The `base` configuration provides a complete development environment without any Claude-specific tools:
- **Development tools**: git, gh, neovim, tmux
- **Modern CLI tools**: bat, eza, fzf, ripgrep
- **Shell environment**: zsh with oh-my-zsh and productivity aliases
- **Auto-loading**: direnv integration for project environments
- **Git configuration**: Pre-configured with sensible defaults

Perfect for developers who want modern tooling but manage Claude separately, or teams that need consistent development environments without AI tooling dependencies.

**Claude + Task Master only** (already shown in Quick Start):
```bash
nix run home-manager -- switch --flake github:smithclay/claude-flake#claude-taskmaster
```
- Claude Code and Task Master
- Claude settings and hook scripts  
- NPM configuration for global packages

## Shell Aliases

The claude-flake loader provides these aliases:

```bash
# Home-manager shortcuts
hm       # nix run home-manager --
hms      # nix run home-manager -- switch --flake $CLAUDE_FLAKE#claude-taskmaster

# Development shell shortcuts
devpy    # nix develop github:smithclay/claude-flake#pythonShell
devrust  # nix develop github:smithclay/claude-flake#rustShell

# Task-master shortcuts
tm       # task-master
```

**Note**: The base configuration includes additional aliases for modern CLI tools. You can add your own aliases in `~/.config/claude-flake/local.sh` which is safe to edit manually.

## Local Development

```bash
git clone https://github.com/smithclay/claude-flake.git
cd claude-flake

# Use locally
nix develop .#pythonShell
nix develop .#rustShell

# Auto-activate with direnv
direnv allow
```

## Integration

Add to your own flake:
```nix
{
  inputs = {
    claude-flake.url = "github:smithclay/claude-flake";
  };
  
  outputs = { self, claude-flake, ... }: {
    devShells = claude-flake.devShells;
  };
}
```

See [development.md](./development.md) for detailed usage and testing.

## Uninstall

To remove the configuration:

```bash
# Remove symlinks and revert to previous home-manager generation
nix run home-manager -- generations  # Find the generation before claude-flake
nix run home-manager -- switch --flake /nix/store/xxx-home-manager-generation-X

# Or manually remove files
rm -rf ~/.claude
rm -rf ~/.config/claude-flake  # Remove loader and configuration
rm -rf ~/.npm-global  # If you want to remove npm packages too

# Remove shell integration (check your shell config files)
# Remove this line from ~/.bashrc or ~/.zshrc:
# [[ -r ~/.config/claude-flake/loader.sh ]] && source ~/.config/claude-flake/loader.sh

# Clean up npm packages (optional)
npm uninstall -g @anthropic-ai/claude-code task-master-ai
```

## Troubleshooting

**Command not found:**
- Ensure you're inside the shell: `nix develop github:smithclay/claude-flake#pythonShell`
- For home-manager tools: `nix run home-manager -- switch --flake github:smithclay/claude-flake#claude-taskmaster`

**nix develop not working:**
- Enable flakes: `echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf`
- Restart shell after enabling flakes

See [development.md](./development.md) for detailed troubleshooting.