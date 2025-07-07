# Development Guide

This guide covers advanced usage, development workflows, and maintenance of claude-flake.

## Table of Contents

- [Local Development (Recommended)](#local-development-recommended)
- [Standalone Home-Manager Installation](#standalone-home-manager-installation)
- [Code Quality Tools](#code-quality-tools)
- [Modern CLI Tools Reference](#modern-cli-tools-reference)
- [Files Copied to Home Directory](#files-copied-to-home-directory)
- [Development and Testing](#development-and-testing)
- [Validation and Linting](#validation-and-linting)
- [Making Changes](#making-changes)
- [Modular Usage](#modular-usage)

## Local Development (Recommended)

**For contributors or users who want simpler commands:**

```bash
# Clone the repository
git clone https://github.com/smithclay/claude-flake.git
cd claude-flake

# Use much simpler local commands
nix develop .#pythonShell       # Instead of long GitHub URL
nix develop .#rustShell         # Much easier to remember
nix develop                     # Default Python shell

# Home-manager configurations
nix run home-manager -- switch --flake .#base
nix run home-manager -- switch --flake .#claude-taskmaster

# Auto-activate environments with direnv (optional)
direnv allow                    # Automatically enters shell when you cd into directory
```

**Benefits of local development:**
- ✅ **Shorter commands** - `nix develop .#pythonShell` vs `nix develop github:smithclay/claude-flake#pythonShell`
- ✅ **Faster iteration** - No network dependency for changes
- ✅ **Easier debugging** - Local files you can inspect and modify
- ✅ **Tab completion** - Your shell can autocomplete local paths
- ✅ **Offline usage** - Works without internet connection

## Standalone Home-Manager Installation

For standalone home-manager with flakes, you don't need channels. Instead:

```bash
# First time setup - creates ~/.config/home-manager/
nix run home-manager/release-25.05 -- init

# Or use our pre-configured home-manager
cd /path/to/claude-flake
nix run home-manager -- switch --flake .#base  # Base development environment
nix run home-manager -- switch --flake .#claude-taskmaster  # Claude + Task Master only
```

## Code Quality Tools

The development shells include `nixfmt-rfc-style` and `statix` for code quality. Use them through the dev environment:

```bash
# Enter development shell
nix develop .

# Format all Nix files
find . -name '*.nix' -type f | xargs nixfmt

# Check all Nix files are properly formatted
find . -name '*.nix' -type f | xargs nixfmt --check

# Check for linting issues
statix check .

# Auto-fix linting issues
statix fix .
```

Or run them directly without entering the shell:
```bash
# Format check (same as CI)
nix develop . --command bash -c "find . -name '*.nix' -type f | xargs nixfmt --check"

# Lint check (same as CI)
nix develop . --command bash -c "statix check ."
```

## Modern CLI Tools Reference

### fd - Better find
```bash
fd                      # List all files (respects .gitignore)
fd -e py               # Find all Python files
fd "test.*\.py"        # Find with regex pattern
fd -x chmod +x         # Execute command on results
```

### bat - Better cat
```bash
bat file.py            # View with syntax highlighting
bat -n --diff file.py  # Show line numbers and Git changes
bat -p file.py         # Plain output (no decorations)
bat --theme=Nord       # Use different color theme
```

### eza - Better ls
```bash
eza -l --icons         # List with icons
eza -la --git          # Show all files with Git status
eza --tree -L 2        # Tree view (max 2 levels)
eza -l --sort=size     # Sort by size
```

### fzf - Fuzzy finder
```bash
# Interactive file search and open in vim
vim $(fzf)

# Search command history (better than Ctrl+R)
history | fzf

# Interactive directory navigation
cd $(find . -type d | fzf)

# Git branch switcher
git checkout $(git branch | fzf)
```

### ripgrep - Better grep
```bash
rg "TODO"              # Search for pattern
rg -t py "import"      # Search only Python files
rg -C 3 "error"        # Show 3 lines of context
rg --hidden "config"   # Include hidden files
```

## Files Copied to Home Directory

When using home-manager, these files are symlinked:
- `~/.claude/settings.json` - Claude CLI configuration
- `~/.claude/CLAUDE.md` - Claude instructions
- `~/.claude/hooks/` - Hook scripts for linting and notifications
- `~/.claude/commands/` - Claude custom commands:
  - `check.md` - Verify code quality and fix all issues
  - `next.md` - Execute production-quality implementation
  - `prompt.md` - Synthesize complete prompts
- `~/.tmux.conf` - Tmux configuration

## Development and Testing

### Testing Dev Shells

```bash
# Test Python shell without entering it
nix develop .#pythonShell --command python --version
nix develop .#pythonShell --command ruff --version

# Test Rust shell
nix develop .#rustShell --command cargo --version
nix develop .#rustShell --command rustc --version

# Run a specific command in the shell
nix develop .#pythonShell --command pytest tests/

# Check what's available in a shell
nix develop .#pythonShell --command "which python poetry ruff black"
```

### Testing Home-Manager Configuration

```bash
# Build without switching (dry run)
nix run home-manager -- build --flake .#base
nix run home-manager -- build --flake .#claude-taskmaster

# See what would change
nix run home-manager -- diff --flake .#base
nix run home-manager -- diff --flake .#claude-taskmaster

# Test specific programs
nix run home-manager -- build --flake .#base && \
  ./result/home-files/.zshrc  # Inspect generated config

# Temporarily test without affecting current environment
nix run .#homeConfigurations.base.activationPackage
nix run .#homeConfigurations.claude-taskmaster.activationPackage
```

## Validation and Linting

```bash
# Validate main flake (includes all modules)
nix flake check              # Main flake

# Show flake info
nix flake show
nix flake metadata

# Update lock files
nix flake update             # Update all inputs
nix flake lock --update-input nixpkgs  # Update specific input
```

## Making Changes

When modifying the flakes:

```bash
# 1. Edit the relevant configuration files
vim devshells/default.nix  # For dev shell changes
vim devshells/python.nix   # For Python-specific changes
vim devshells/rust.nix     # For Rust-specific changes

# 2. Test your changes immediately
nix develop .#pythonShell --command "python -c 'import sys; print(sys.version)'"

# 3. Check for errors
nix flake check .

# 4. Commit when satisfied
git add -A && git commit -m "Add new Python package"
```

## Modular Usage

Each component can be used independently:

```bash
# Use development shells directly
nix develop github:smithclay/claude-flake#pythonShell
nix develop github:smithclay/claude-flake#rustShell

# Use home configurations
nix run home-manager -- switch --flake github:smithclay/claude-flake#base
nix run home-manager -- switch --flake github:smithclay/claude-flake#claude-taskmaster
```

## Updating

```bash
# Update flake inputs
nix flake update

# Update home configuration
nix run home-manager -- switch --flake .#base
nix run home-manager -- switch --flake .#claude-taskmaster

# Update dev shells (happens automatically)
nix develop .
```