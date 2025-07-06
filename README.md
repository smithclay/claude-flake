# Modular Nix Development Environment

A modular Nix flake setup providing separate development shells and home-manager configuration with AI tooling support.

## Project Structure

```
.
├── flake.nix              # Main flake that imports both sub-flakes
├── dev-shells/
│   └── flake.nix         # Development shells (Python, Rust)
├── home-manager/
│   └── flake.nix         # Home-manager configuration
└── .envrc                # Direnv integration for auto-loading shells
```

## Prerequisites

- Nix with flakes enabled
- Home-manager (optional, for system configuration)
- Direnv (optional, for automatic shell activation)

## Quick Start

### 1. Enable Nix Flakes (if not already enabled)

```bash
echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf
```

### 2. Install Home-Manager (Standalone)

For standalone home-manager with flakes, you don't need channels. Instead:

```bash
# First time setup - creates ~/.config/home-manager/
nix run home-manager/release-25.05 -- init

# Or use our pre-configured home-manager
cd /path/to/genai-nix-flake
nix run home-manager -- switch --flake ./home-manager#clay
```

### 3. Use Development Shells

```bash
# Enter default shell (Python)
nix develop ./dev-shells

# Or use specific shells
nix develop ./dev-shells#pythonShell
nix develop ./dev-shells#rustShell

# From the root directory (re-exported)
nix develop
```

#### With Direnv (Automatic Shell Activation)

```bash
# Allow direnv to load the shell automatically
direnv allow

# Now the Python shell loads automatically when entering the directory!
```

### 4. Apply Home Configuration (Optional)

```bash
# Build and switch to the home configuration
home-manager switch --flake ./home-manager#clay
```

This installs:
- Zsh with oh-my-zsh
- Developer tools: fd, bat, eza, fzf
- Basic utilities: git, tmux, ripgrep, etc.
- Claude CLI configuration
- Direnv with nix-direnv integration

## What's Included

### Global (Home-Manager)
- **Shell**: Zsh with oh-my-zsh plugins
- **Editor**: Neovim (aliased as vim/vi)
- **Modern CLI tools**: 
  - `fd` - Better find (faster, intuitive syntax, respects .gitignore)
  - `bat` - Better cat with syntax highlighting and Git integration
  - `eza` - Better ls with icons, Git status, and tree view
  - `fzf` - Fuzzy finder for files, history, commands, and more
  - `ripgrep` - Lightning-fast grep alternative
- **Utilities**: git, gh, tmux, jq, yq, tree, htop, curl, wget
- **Languages**: Node.js 22
- **Config Files**: Claude settings, tmux config, hook scripts
- **Integration**: Direnv with nix-direnv

### Python Development Shell
- Python 3 with pip, virtualenv
- **Formatters**: black, ruff
- **Linters**: flake8, mypy
- **Testing**: pytest
- **REPL**: ipython
- **Package Management**: poetry
- Node.js 22
- Claude CLI check and Task Master check

### Rust Development Shell
- **Toolchain**: rustc, cargo, rustfmt, clippy
- **IDE Support**: rust-analyzer
- **Build dependencies**: pkg-config, openssl
- Node.js 22
- Claude CLI check and Task Master check

## Modern CLI Tools Usage

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

## Shell Aliases

```bash
# Modern CLI replacements
ll       # eza -l (better ls)
la       # eza -la
lt       # eza --tree
cat      # bat (syntax highlighting)
find     # fd (faster, user-friendly)

# Git shortcuts
gs       # git status
gd       # git diff
gc       # git commit
gp       # git push

# Development shortcuts
dev      # nix develop (default Python shell)
devpy    # nix develop ../dev-shells#pythonShell
devrust  # nix develop ../dev-shells#rustShell

# Others
vim/vi   # neovim
py       # python3
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

## Updating

```bash
# Update flake inputs
nix flake update

# Update home configuration
home-manager switch --flake ./home-manager#clay

# Update dev shells (happens automatically)
nix develop ./dev-shells
```

## Development and Testing

### Testing Dev Shells

```bash
# Test Python shell without entering it
nix develop ./dev-shells#pythonShell --command python --version
nix develop ./dev-shells#pythonShell --command ruff --version

# Test Rust shell
nix develop ./dev-shells#rustShell --command cargo --version
nix develop ./dev-shells#rustShell --command rustc --version

# Run a specific command in the shell
nix develop ./dev-shells#pythonShell --command pytest tests/

# Check what's available in a shell
nix develop ./dev-shells#pythonShell --command "which python poetry ruff black"
```

### Testing Home-Manager Configuration

```bash
# Build without switching (dry run)
home-manager build --flake ./home-manager#clay

# See what would change
home-manager diff --flake ./home-manager#clay

# Test specific programs
home-manager build --flake ./home-manager#clay && \
  ./result/home-files/.zshrc  # Inspect generated config

# Temporarily test without affecting current environment
nix run ./home-manager#homeConfigurations.clay.activationPackage
```

### Validation and Linting

```bash
# Validate all flakes
nix flake check              # Main flake
nix flake check ./dev-shells # Dev shells flake  
nix flake check ./home-manager # Home-manager flake

# Show flake info
nix flake show
nix flake metadata

# Update lock files
nix flake update             # Update all inputs
nix flake lock --update-input nixpkgs  # Update specific input
```

### Making Changes

When modifying the flakes:

```bash
# 1. Edit the relevant flake.nix
vim dev-shells/flake.nix

# 2. Test your changes immediately
nix develop ./dev-shells#pythonShell --command "python -c 'import sys; print(sys.version)'"

# 3. Check for errors
nix flake check ./dev-shells

# 4. Commit when satisfied
git add -A && git commit -m "Add new Python package"
```

## Modular Usage

Each component can be used independently:

```bash
# Use only dev shells from another project
nix develop github:yourusername/genai-nix-flake?dir=dev-shells

# Use only home config
home-manager switch --flake github:yourusername/genai-nix-flake?dir=home-manager#clay
```

## Troubleshooting

**Command not found errors:**
1. For home-manager packages: Run `nix run home-manager -- switch --flake ./home-manager#clay`
2. For dev shell tools: Enter the shell with `nix develop`
3. Check PATH includes `~/.nix-profile/bin`

**home-manager command not found:**
With flakes, home-manager isn't installed globally. Use one of:
- `nix run home-manager -- <command>`
- Add alias: `alias hm="nix run home-manager --"`
- The pre-configured alias: `hms` (after applying config)

**Direnv not working:**
1. Install direnv: `nix-env -iA nixpkgs.direnv`
2. Hook into your shell (add to ~/.zshrc): `eval "$(direnv hook zsh)"`
3. Allow the .envrc: `direnv allow`

**Claude/Task Master warnings:**
- These are npm global packages - warnings are expected
- They're checked but not auto-installed to avoid conflicts