# Nix Development Environment

A Nix flake providing development shells for Python and Rust with home-manager configuration.

## Prerequisites

- Nix with flakes enabled
- Home-manager

## Quick Start

### 1. Enable Nix Flakes (if not already enabled)

```bash
echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf
```

### 2. Install Home-Manager

```bash
nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
nix-channel --update
```

### 3. Apply Home Configuration

```bash
# Build and switch to the home configuration
home-manager switch --flake .#clay
```

This installs:
- Zsh with oh-my-zsh
- Neovim
- Basic utilities (git, tmux, ripgrep, etc.)
- Claude CLI configuration
- Basic Python/Rust for scripts

### 4. Use Development Shells

```bash
# Python development environment
nix develop .#pythonShell

# Rust development environment  
nix develop .#rustShell
```

## What's Included

### Global (Home-Manager)
- **Shell**: Zsh with oh-my-zsh plugins
- **Editor**: Neovim (aliased as vim/vi)
- **Utilities**: git, tmux, ripgrep, jq, tree, htop
- **Languages**: Basic Python 3 and Rust for scripts
- **Config Files**: Claude settings, tmux config, taskmaster config

### Python Shell
- Python 3 with pip
- Development tools: black, flake8, pytest, ipython, virtualenv
- Node.js 20
- Claude CLI (@anthropic-ai/claude-cli)
- Task Master AI (task-master-ai)

### Rust Shell
- Rust toolchain: rustc, cargo, rustfmt, clippy
- rust-analyzer for IDE support
- Build dependencies: pkg-config, openssl
- Node.js 20
- Claude CLI (@anthropic-ai/claude-cli)
- Task Master AI (task-master-ai)

## Shell Aliases

```bash
# Git shortcuts
gs    # git status
gd    # git diff
gc    # git commit
gp    # git push

# Development shortcuts
devpy    # nix develop .#pythonShell
devrust  # nix develop .#rustShell

# Others
vim/vi   # neovim
py       # python3
```

## Files Copied to Home Directory

- `~/.claude/settings.json` - Claude CLI configuration
- `~/.claude/CLAUDE.md` - Claude instructions
- `~/.claude/hooks/` - Hook scripts for linting and notifications
- `~/.tmux.conf` - Tmux configuration
- `~/.taskmaster/config.json` - Task Master configuration

## Updating

To update the configuration after changes:

```bash
home-manager switch --flake .#clay
```

## Troubleshooting

If you get "command not found" errors:
1. Make sure you've run `home-manager switch`
2. Restart your shell or source your profile
3. Check that `~/.nix-profile/bin` is in your PATH