# claude-flake

[![CI](https://github.com/smithclay/claude-flake/actions/workflows/ci.yml/badge.svg)](https://github.com/smithclay/claude-flake/actions/workflows/ci.yml)
[![NixOS](https://img.shields.io/badge/NixOS-5277C3?style=flat&logo=nixos&logoColor=white)](https://nixos.org)
[![Flakes](https://img.shields.io/badge/Nix-Flakes-blue)](https://nixos.wiki/wiki/Flakes)

**Opinionated Claude Code workflow with built-in config, hooks and commands.**

Claude Code is a powerful AI coding agent from Anthropic that works in your terminal. This setup helps makes it more effective, plus task management + development tools that work consistently across all machines.

## 🤖 What You Get

**Opinionated workflow** = The primary benefit - no decisions needed:
- Research → Plan → Implement process built into commands
- Quality checks that run automatically 
- Proven patterns from the Claude Code community
- Everything pre-configured to work together
- Language-specific development shells with all tools included

**Claude Code** = Powerful AI coding agent that:
- Reads and understands your entire project
- Writes code that matches your style and patterns  
- Explains complex code in plain English
- Helps debug errors and suggests fixes
- Works in your terminal

**Plus:** Modern development tools that make terminal work actually enjoyable.

## 📋 Requirements & Setup

**You need:**
- **Docker** (recommended) OR **Nix** (advanced)
- **Anthropic API key** ($20 gets you ~1M tokens) OR **Claude Pro subscription** ($20/month)
- Any coding project where you want AI help

**Supported systems:** Linux, macOS, Windows (via WSL - Windows Subsystem for Linux)

**Language Shells:** Enter dedicated development environments with all the tools you need:
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
- Install modern development tools
- Configure shell integration

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
  ghcr.io/smithclay/claude-flake:latest
```

**You're now inside the container with a bash shell. Your project files are at /workspace**

**Step 3: Start using Claude**
```bash
# Start Claude Code (you'll be prompted for your API key on first run)
claude

# You'll see something like this:
# > Enter your message: help me understand this codebase
# > Claude: I can see you have a Python project with Flask...

# All modern dev tools are available
git status
eza -la     # Better 'ls' - shows file types and permissions clearly
rg "TODO"   # Better 'grep' - faster searching with syntax highlighting
```

**Step 4: Use language-specific development shells (optional)**
```bash
# Enter a language-specific shell with appropriate tools
cf dev rust     # For Rust projects
cf dev python   # For Python projects  
cf dev nodejs   # For Node.js projects
cf dev go       # For Go projects
cf dev nix      # For Nix projects

# Auto-detect project type and enter appropriate shell
cf              # Automatically detects and enters the right shell

# Override flake source to use local development version:
export CLAUDE_FLAKE_SOURCE=path:/path/to/local/claude-flake
cf dev rust     # Now uses your local flake instead of GitHub
```

### Docker Workflow

1. **Daily development**: Start the container with your project mounted
2. **Optional performance optimization**: Add cache volume for faster Nix operations:
   ```bash
   docker run -it \
     -v $(pwd):/workspace \
     -v ~/.claude/.credentials.json:/home/claude/.claude/.credentials.json:ro \
     -v claude-cache:/home/claude/.cache/nix \
     ghcr.io/smithclay/claude-flake:latest
   ```
3. **Work normally**: Use Claude Code, edit files, run tests - everything stays in sync with your local filesystem

## 📝 Step-by-Step Development Workflow

### Setting Up a New Project

1. **Create or navigate to your project directory**
   ```bash
   mkdir my-ai-project && cd my-ai-project
   ```

2. **Start claude-flake environment**
   ```bash
   # Docker way (recommended - includes Claude credentials mounting)
   docker run -it \
     -v $(pwd):/workspace \
     -v ~/.claude/.credentials.json:/home/claude/.claude/.credentials.json:ro \
     ghcr.io/smithclay/claude-flake:latest
   
   # OR Nix way (if you have Nix installed)
   nix run --impure --accept-flake-config github:smithclay/claude-flake#apps.x86_64-linux.home
   ```

3. **Use language-specific shells for your project**
   ```bash
   # Use the unified cf command for quick access:
   cf dev python   # 🐍 Python development shell
   cf dev rust     # 🦀 Rust development shell
   cf dev nodejs   # 🟢 Node.js development shell
   cf dev go       # 🐹 Go development shell
   cf dev nix      # ❄️ Nix development shell
   
   # Auto-detect project type and enter appropriate shell
   cf              # Automatically detects and enters the right shell
   
   # Override flake source for local development:
   export CLAUDE_FLAKE_SOURCE=path:/path/to/local/claude-flake
   cf dev python   # Now uses your local flake
   
   # Check available commands and current source:
   cf help         # Shows all commands and usage information
   cf status       # Shows current environment and project detection
   ```

### Daily Development Loop

1. **Start your environment** (same command as setup)
2. **Use Claude for AI assistance**
   ```bash
   claude
   # Example conversations:
   # "Explain what this function does"
   # "Help me fix this bug: [paste error]"
   # "Write a function that validates email addresses"
   # "Review this code for security issues"
   ```
3. **Use enhanced development tools**
   ```bash
   # Modern CLI tools that are actually better:
   eza -la              # File listing with colors and icons
   rg "search term"     # Text search that's 10x faster than grep
   bat filename.py      # File viewing with syntax highlighting
   ```

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

If you prefer to install directly on your system:

**Step 1: Install Nix** (if not already installed)
```bash
curl -L https://install.determinate.systems/nix | sh -s -- install
```

**Step 2: Enable flakes**
```bash
echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf
# Restart your shell after this
```

**Step 3: Install claude-flake**
```bash
nix run --impure --accept-flake-config github:smithclay/claude-flake#apps.x86_64-linux.home
```

This automatically:
- Installs Claude Code and Task Master
- Configures your shell (bash/zsh) with helpful aliases
- Sets up a universal development environment
- Makes language-specific shells available via `nix develop`

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

## 🛠️ CF Command Reference

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

### **Examples**
```bash
# Auto-detect and enter appropriate shell
cf

# Enter specific language shell
cf dev python
cf dev rust

# Check environment health
cf doctor

# See current status
cf status

# Get help
cf help

# Use local development version
export CLAUDE_FLAKE_SOURCE=path:/path/to/local/claude-flake
cf dev nix
```


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

## 🎯 What's Included

| Tool | Purpose |
|------|---------|
| **Claude Code** | AI pair programming assistant |
| **Modern CLI Tools** | bat, eza, fzf, ripgrep, jq for better terminal experience |
| **Development Tools** | git, gh, neovim |
| **Language Shells** | Dedicated environments for Python, Rust, Go, Node.js, Nix with all tools |
| **Shell Integration** | Automatic aliases, functions, and prompt indicators |

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

**CF Command Issues:**
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

**Need a specific language shell?** After installation, use the unified cf command:
```bash
cf dev python   # 🐍 Enter Python development shell with poetry, black, pytest, etc.
cf dev rust     # 🦀 Enter Rust development shell with cargo, clippy, rust-analyzer, etc.
cf dev nodejs   # 🟢 Enter Node.js development shell with eslint, prettier, typescript, etc.
cf dev go       # 🐹 Enter Go development shell with gopls, golangci-lint, etc.
cf dev nix      # ❄️ Enter Nix development shell with nixfmt, statix, etc.

# Auto-detect and enter appropriate shell for your project
cf              # Automatically detects project type and enters right shell

# For local development of claude-flake itself:
export CLAUDE_FLAKE_SOURCE=path:/path/to/local/claude-flake
cf dev python   # Uses your local flake instead of GitHub
cf help         # Shows all commands and usage instructions
cf doctor       # Diagnose environment and configuration
```

**What's WSL?** On Windows, you need Windows Subsystem for Linux to run Docker and development tools. Install "Ubuntu" from Microsoft Store, then use that terminal.