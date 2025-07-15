# claude-flake

[![CI](https://github.com/smithclay/claude-flake/actions/workflows/ci.yml/badge.svg)](https://github.com/smithclay/claude-flake/actions/workflows/ci.yml)
[![NixOS](https://img.shields.io/badge/NixOS-5277C3?style=flat&logo=nixos&logoColor=white)](https://nixos.org)
[![Flakes](https://img.shields.io/badge/Nix-Flakes-blue)](https://nixos.wiki/wiki/Flakes)

**Opinionated Claude Code workflow with built-in config, hooks, dev environments, and commands.**

This project helps make [Claude Code](https://www.anthropic.com/claude-code), a powerful AI coding agent from Anthropic, more effective.

## 🤖 What you get

**Opinionated workflow**
- Research → Plan → Implement process built into commands
- Quality checks that run automatically 
- Proven patterns from the Claude Code community
- Everything pre-configured to work together
- Language-specific development shells with all tools included
- Notifications to your iOS/macOS devices with [nfty](https://ntfy.sh/) for long-running tasks.

**Plus:** Management of everything is orchestrated using a [nix flake](https://nixos.wiki/wiki/flakes), if you're into that.

## 📋 Requirements

**You need:**
- **Docker** (recommended) OR **Nix** (advanced)
- **Anthropic API key** OR **Claude Pro subscription** ($20/month)
- Any coding project where you want AI help

**Supported systems:** Linux, macOS, Windows (via WSL - Windows Subsystem for Linux)

**Language Shells:** Dedicated development environments with all the tools you need (optional):
- 🦀 Rust: cargo, clippy, rust-analyzer, rustfmt, cargo-watch
- 🐍 Python: poetry, black, pytest, mypy, ruff
- 🟢 Node.js: yarn, pnpm, eslint, prettier, typescript
- 🐹 Go: gopls, golangci-lint, gofumpt, delve
- ❄️ Nix: nixfmt, statix, deadnix, nil

## ⚡ Quick Install (Recommended)

**One command installs everything:**

```bash
curl -sSL https://raw.githubusercontent.com/smithclay/claude-flake/main/install.sh | bash
```

This interactive installer will:
- Check your system requirements
- Let you choose Docker or Nix installation
- Set up Claude Code with optimized configuration

**Then get your API key:**

1. Go to [console.anthropic.com](https://console.anthropic.com) for API key OR [claude.ai](https://claude.ai) for Pro subscription
2. Sign up and choose: API credits ($20) or Claude Pro ($20/month)
3. Create an API key (if using API) or note your Pro login
4. Run `claude` to add your credentials

## 🐳 Manual Docker Setup (Alternative)

**Step 1: Navigate to your project directory**
```bash
# On your computer, go to your project folder
cd /path/to/your/project
# For example: cd ~/my-python-app
```

**Step 2: Run the container**
```bash
# This mounts your current directory and Claude credentials to the container
# The ~/.claude mount will pick up and save your existing Claude Code credentials
docker run -it \
  -v $(pwd):/workspace \
  -v ~/.claude/.credentials.json:/home/claude/.claude/.credentials.json:ro \
  -v claude-cache:/home/claude/.cache/nix \
  ghcr.io/smithclay/claude-flake:latest
```

**You're now inside the container with a bash shell. Your project files are at /workspace**

**Step 3: Use language-specific development shell**
```bash
# Enter a language-specific shell with appropriate tools
cf dev rust     # For Rust projects
cf dev python   # For Python projects  
cf dev nodejs   # For Node.js projects
cf dev go       # For Go projects
cf dev nix      # For Nix projects
```

**Step 4: Start using Claude Code**
```bash
# Start Claude Code (you'll be prompted for your API key on first run)
claude

# Run the built in commands to help you write code. Validation hooks will run automatically.
# > /next Let's add a new API endpoint to this project...
```

**Step 4: Work normally with Claude Code**

Use Claude Code, edit files, run tests - everything stays in sync with your local filesystem.

### 🎯 Real Example: Building a Simple API

Here's what using Claude Code with pre-configured commands looks like:

```bash
# 1. Start with planning
claude
> "/next I want to build a REST API in Python"

# Claude follows the Research → Plan → Implement workflow
# Suggests Flask, creates implementation plan, asks for approval

# 2. Get specific help
> "Write a Flask route that accepts JSON and validates email addresses"

# Claude writes the code, explains validation options

# 3. Check your work
> "/check"

# Runs all quality checks: linting, tests, formatting
# Ensures production-ready code before continuing

# 4. Debug issues
> "I'm getting 'ImportError: No module named flask'. How do I fix this?"

# Claude explains virtual environments and gives exact commands
```

### Language-Specific Enhancements

When you enter a language-specific shell, you get appropriate tools:

- **Python projects** 🐍: Poetry, Black, pytest, mypy, ruff, bandit, isort
- **Rust projects** 🦀: Cargo, Clippy, rust-analyzer, rustfmt, cargo-watch, cargo-audit
- **Go projects** 🐹: Go toolchain, gopls, golangci-lint, delve, gosec, gofumpt
- **Node.js projects** 🟢: npm/yarn/pnpm, ESLint, Prettier, TypeScript, stylelint
- **Nix projects** ❄️: nixfmt, statix, nil language server, deadnix, nix-tree

## 💻 Installation without Docker

If you prefer to install directly on your system, run `curl -L https://install.determinate.systems/nix | sh -s -- install` and choose "nix" to install.

## 🚀 Using Language-Specific Shells

Once installed, you can enter development shells tailored for your project type:

```bash
# Use the unified cf command for language shells
cf dev rust     # Rust: cargo, clippy, rust-analyzer
cf dev python   # Python: poetry, black, pytest, mypy
cf dev nodejs   # Node.js: yarn, pnpm, eslint, prettier
cf dev go       # Go: gopls, golangci-lint, delve
cf dev nix      # Nix: nixfmt, statix, nil

# Auto-detect project type and enter appropriate shell
cf              # Automatically detects and enters the right shell

# Override flake source for local development
export CLAUDE_FLAKE_SOURCE=path:/path/to/local/claude-flake
cf dev rust     # Now uses your local flake

# See all available commands and system status
cf help         # Shows all commands and usage instructions
cf status       # Shows current environment and project detection
cf doctor       # Diagnose environment and configuration issues
```

Each shell includes:
- Language-specific linters and formatters
- LSP servers for editor integration
- Testing frameworks
- Build tools
- Security scanners

## 🛠️ `cf` Command Reference

The `cf` command is your unified interface to claude-flake functionality:

### **Basic Usage**
```bash
cf                    # Auto-detect project type and enter development shell
cf dev [language]     # Enter specific language development shell
```

### **Available Commands**
```bash
cf help              # Show comprehensive usage information
cf version           # Show claude-flake version and components
cf status            # Show current environment and project status
cf doctor            # Diagnose environment and configuration issues
cf update            # Update claude-flake to latest version
```

### **Supported Languages**
- `rust` - Rust development environment (cargo, clippy, rust-analyzer)
- `python` - Python development environment (poetry, black, pytest, mypy)
- `nodejs` - Node.js development environment (yarn, pnpm, eslint, prettier)
- `go` - Go development environment (go toolchain, gopls, golangci-lint)
- `nix` - Nix development environment (nixfmt, statix, nil LSP)
- `java` - Java development environment (maven, gradle, spotbugs)
- `cpp` - C++ development environment (cmake, clang-tools, gdb)
- `shell` - Shell scripting environment (shellcheck, shfmt)
- `universal` - Universal development environment (git, neovim, modern CLI tools)

### **Project Auto-Detection**
The `cf` command automatically detects your project type based on files:
- **Rust**: `Cargo.toml`, `Cargo.lock`
- **Python**: `pyproject.toml`, `requirements.txt`, `poetry.lock`
- **Node.js**: `package.json`, `yarn.lock`, `package-lock.json`
- **Go**: `go.mod`, `go.sum`
- **Nix**: `flake.nix`, `shell.nix`, `default.nix`
- **Java**: `pom.xml`, `build.gradle`
- **C++**: `CMakeLists.txt`, `Makefile`

### **Environment Variables**
- `CLAUDE_FLAKE_SOURCE` - Override flake source (default: `github:smithclay/claude-flake`)
- `CF_SHELL` - Current shell type (set automatically when in a cf shell)

## 🗑️ Uninstall

Use the same installation script with the `--uninstall` flag:

```bash
curl -sSL https://raw.githubusercontent.com/smithclay/claude-flake/main/install.sh | bash -s -- --uninstall
```

This will:
- Detect your installation method (Docker or Nix)
- Safely remove all claude-flake components
- Offer to restore configuration backups (Nix installations)
- Clean up all associated files and packages

**Manual removal (if needed):**

### Remove Docker setup
```bash
# Remove containers and images
docker container prune
docker image rm ghcr.io/smithclay/claude-flake:latest

# Remove cache volume (optional - improves Nix performance)
docker volume rm claude-cache

# Remove wrapper script
rm ~/.local/bin/cf-docker
```

### Remove Nix installation
```bash
# Remove installed packages
npm uninstall -g @anthropic-ai/claude-code

# Clean up directories
rm -rf ~/.claude ~/.config/claude-flake ~/.npm-global

# Remove shell integration
sed -i '/claude-flake\/loader\.sh/d' ~/.bashrc ~/.zshrc
```

## 🙏 Credits

Built upon the excellent work at [Veraticus/nix-config](https://github.com/Veraticus/nix-config/tree/main/home-manager/claude-code) - thank you for pioneering Claude Code configuration with Nix.

## 💡 Troubleshooting

### **Quick Diagnostics**
**First, always run the built-in diagnostics:**
```bash
cf doctor    # Comprehensive environment check
cf status    # Current environment and project detection
cf version   # Version information and dependencies
```

### **Common Issues and Solutions**

**Installation Issues:**
- `docker: command not found` → Install Docker Desktop from docker.com
- `cf: command not found` → Restart your terminal after installation or check if you're in a cf shell
- `Permission denied` on Docker → Add yourself to docker group: `sudo usermod -aG docker $USER` then restart terminal
- "WSL not found" on Windows → Install from Microsoft Store, then restart

**Claude Code Issues:**
- `claude: command not found` → Check `cf doctor` output and restart terminal after installation
- API key not working → Make sure you have credits in your Anthropic account, verify with `cf doctor`
- Claude hanging or slow → Check network connectivity with `cf doctor`

**cf Command Issues:**
- `cf` auto-detection wrong → Use explicit `cf dev [language]` or check project files
- Can't enter shell → Check `cf doctor` for Nix installation and flake accessibility
- Stuck in nested shell → Use `exit` to leave current shell, check `cf status`
- Environment variables not working → Verify with `cf status` and restart shell

**Network and Update Issues:**
- Flake not accessible → Check `cf doctor` for network connectivity and flake validation
- Update failing → Run `cf doctor` to diagnose, check internet connection
- Slow Nix operations → Add cache volume in Docker or check substituters in `cf doctor`

### **Diagnostic Workflow**
```bash
# Step 1: Get overview
cf doctor              # Shows all environment checks

# Step 2: Check current state  
cf status              # Shows project detection and current shell

# Step 3: Get version info
cf version             # Shows versions and available environments

# Step 4: Test functionality
cf help                # Verify cf command works
cf dev universal       # Test entering a basic shell
exit                   # Exit and try auto-detection
cf                     # Test auto-detection
```
