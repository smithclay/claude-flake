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

**Task Master** = Like a PM for AI agents - helps you:
- Break big features into small tasks
- Track what you've completed
- Research solutions for complex problems

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

## 🔑 Get Access First

1. Go to [console.anthropic.com](https://console.anthropic.com) for API key OR [claude.ai](https://claude.ai) for Pro subscription
2. Sign up and choose: API credits ($20) or Claude Pro ($20/month)
3. Create an API key (if using API) or note your Pro login
4. Save it - you'll add it to Claude Code during setup

## 🐳 Quick Start with Docker (Recommended)

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

# Task Master for simple todo lists
task-master

# All modern dev tools are available
git status
eza -la     # Better 'ls' - shows file types and permissions clearly
rg "TODO"   # Better 'grep' - faster searching with syntax highlighting
```

**Step 4: Use language-specific development shells (optional)**
```bash
# Enter a language-specific shell with appropriate tools
nix develop github:smithclay/claude-flake#rust     # For Rust projects
nix develop github:smithclay/claude-flake#python   # For Python projects
nix develop github:smithclay/claude-flake#nodejs   # For Node.js projects
# Tools are automatically available in the shell
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
   # Enter the appropriate development shell with all tools pre-installed
   nix develop github:smithclay/claude-flake#python   # 🐍 Python development
   nix develop github:smithclay/claude-flake#rust     # 🦀 Rust development
   nix develop github:smithclay/claude-flake#nodejs   # 🟢 Node.js development
   nix develop github:smithclay/claude-flake#go       # 🐹 Go development
   nix develop github:smithclay/claude-flake#nix      # ❄️ Nix development
   
   # Or use the cf-* aliases after installation:
   cf-python   # Quick access to Python shell
   cf-rust     # Quick access to Rust shell
   cf-nodejs   # Quick access to Node.js shell
   cf-go       # Quick access to Go shell
   cf-nix      # Quick access to Nix shell
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
3. **Manage tasks with Task Master**
   ```bash
   task-master init           # Set up project todos
   task-master next          # Get next task to work on
   task-master add-task "add user authentication"
   ```
4. **Use enhanced development tools**
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
# Enter a shell with all tools for your language
nix develop github:smithclay/claude-flake#rust     # Rust: cargo, clippy, rust-analyzer
nix develop github:smithclay/claude-flake#python   # Python: poetry, black, pytest, mypy
nix develop github:smithclay/claude-flake#nodejs   # Node.js: yarn, pnpm, eslint, prettier
nix develop github:smithclay/claude-flake#go       # Go: gopls, golangci-lint, delve
nix develop github:smithclay/claude-flake#nix      # Nix: nixfmt, statix, nil

# Or use shortcuts (after sourcing ~/.config/claude-flake/loader.sh)
cf-rust    # Quick access to Rust shell
cf-python  # Quick access to Python shell
cf-nodejs  # Quick access to Node.js shell
cf-go      # Quick access to Go shell
cf-nix     # Quick access to Nix shell
```

Each shell includes:
- Language-specific linters and formatters
- LSP servers for editor integration
- Testing frameworks
- Build tools
- Security scanners

## 🗑️ Uninstall

### Remove Docker setup
```bash
# Remove containers and images
docker container prune
docker image rm ghcr.io/smithclay/claude-flake:latest

# Remove cache volume (optional - improves Nix performance)
docker volume rm claude-cache
```

### Remove Nix installation
```bash
# Revert shell configuration
nix run home-manager -- generations  # Find previous generation
nix run home-manager -- switch --flake /nix/store/xxx-home-manager-generation-X

# Remove installed packages
npm uninstall -g @anthropic-ai/claude-code task-master-ai

# Clean up directories
rm -rf ~/.claude ~/.config/claude-flake ~/.npm-global
```

## 🎯 What's Included

| Tool | Purpose |
|------|---------|
| **Claude Code** | AI pair programming assistant |
| **Task Master** | AI-powered project management |
| **Modern CLI Tools** | bat, eza, fzf, ripgrep, jq for better terminal experience |
| **Development Tools** | git, gh, neovim |
| **Language Shells** | Dedicated environments for Python, Rust, Go, Node.js, Nix with all tools |
| **Shell Integration** | Automatic aliases, functions, and prompt indicators |

## 🙏 Credits

Built upon the excellent work at [Veraticus/nix-config](https://github.com/Veraticus/nix-config/tree/main/home-manager/claude-code) - thank you for pioneering Claude Code configuration with Nix.

## 💡 Need Help?

**Common issues:**
- `docker: command not found` → Install Docker Desktop from docker.com
- `claude: command not found` → Restart your terminal after installation
- `Permission denied` on Docker → Add yourself to docker group: `sudo usermod -aG docker $USER` then restart terminal
- API key not working → Make sure you have credits in your Anthropic account
- "WSL not found" on Windows → Install from Microsoft Store, then restart

**Need a specific language shell?** After installation, use the aliases:
```bash
cf-python   # 🐍 Enter Python development shell with poetry, black, pytest, etc.
cf-rust     # 🦀 Enter Rust development shell with cargo, clippy, rust-analyzer, etc.
cf-nodejs   # 🟢 Enter Node.js development shell with eslint, prettier, typescript, etc.
cf-go       # 🐹 Enter Go development shell with gopls, golangci-lint, etc.
cf-nix      # ❄️ Enter Nix development shell with nixfmt, statix, etc.
```

**What's WSL?** On Windows, you need Windows Subsystem for Linux to run Docker and development tools. Install "Ubuntu" from Microsoft Store, then use that terminal.