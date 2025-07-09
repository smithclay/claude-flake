# Manual Installation Guide

> **Phase 2A**: Manual home-manager integration with shell loader

This guide provides manual installation steps for Claude-Flake home-manager integration.

## Prerequisites

- Nix package manager with flakes enabled
- Home-manager (will be installed automatically if not present)

## Installation Steps

### 1. Run the Setup Command

Choose the appropriate command for your system:

```bash
# For most Linux systems (x86_64)
nix run nixpkgs#home-manager --accept-flake-config -- switch --flake github:smithclay/claude-flake#user@linux

# For ARM64 Linux
nix run nixpkgs#home-manager --accept-flake-config -- switch --flake github:smithclay/claude-flake#user@aarch64-linux

# For macOS (Intel)
nix run nixpkgs#home-manager --accept-flake-config -- switch --flake github:smithclay/claude-flake#user@darwin

# For macOS (Apple Silicon)
nix run nixpkgs#home-manager --accept-flake-config -- switch --flake github:smithclay/claude-flake#user@aarch64-darwin
```

### 2. Manual Shell Integration (Required)

The setup creates a loader script but does NOT automatically modify your shell configuration. 
You must manually add the loader to your shell configuration:

#### For Bash users:
Add to your `~/.bashrc`:
```bash
# Source Claude-Flake loader
[[ -r ~/.config/claude-flake/loader.sh ]] && source ~/.config/claude-flake/loader.sh
```

#### For Zsh users:
Add to your `~/.zshrc`:
```bash
# Source Claude-Flake loader
[[ -r ~/.config/claude-flake/loader.sh ]] && source ~/.config/claude-flake/loader.sh
```

### 3. Reload Your Shell

Either start a new terminal session or run:
```bash
source ~/.bashrc    # For bash
source ~/.zshrc     # For zsh
```

## What Gets Installed

- Claude CLI (`claude` command)
- Task Master (`task-master` and `tm` commands)
- Modern CLI tools (bat, eza, fzf, ripgrep)
- Development tools (git, gh, neovim)
- Language runtimes (Node.js, Python)

## Available Commands

After installation and shell reload:
```bash
claude          # Start Claude Code
task-master     # Task Master CLI
tm              # Task Master shortcut
hm              # Home-manager shortcut
check           # Claude /check command
next            # Claude /next command
prompt          # Claude /prompt command
ll              # Enhanced ls with eza
cat             # Enhanced cat with bat
grep            # Enhanced grep with ripgrep
```

## Customization

Create `~/.config/claude-flake/local.sh` for your custom aliases and configurations:
```bash
#!/usr/bin/env bash
# Your custom aliases and functions
alias myproject="cd ~/projects/myproject && claude"
export MY_CUSTOM_VAR="value"

# Example: Project-specific aliases
alias webdev="cd ~/projects/web && claude"
alias backend="cd ~/projects/api && claude"
```

## Troubleshooting

### Command not found after installation
- Ensure you've manually added the loader to your shell configuration
- Reload your shell: `source ~/.bashrc` or `source ~/.zshrc`
- Check that the loader file exists: `ls -la ~/.config/claude-flake/loader.sh`

### Home-manager installation failed
```bash
# Install home-manager manually
nix profile install nixpkgs#home-manager

# Then retry the setup
nix run nixpkgs#home-manager --accept-flake-config -- switch --flake github:smithclay/claude-flake#user@linux
```

### Permission issues
- Ensure you have write permissions to your home directory
- Check that Nix is properly installed and configured

## Verification

Once manual installation is complete:
1. Test Claude CLI: `claude --help`
2. Test Task Master: `task-master --help`
3. Verify enhanced commands work: `ll`, `cat README.md`, `grep "test" *`
4. Check loader status: `echo "Loader loaded: $(type -t hm)"`

## Roadmap

- **Phase 2B**: Docker quickstart option
- **Phase 3A**: Automatic shell integration (no manual steps required)
- **Phase 4**: Advanced language detection and optimization
- **Phase 5**: IDE integrations and advanced tooling