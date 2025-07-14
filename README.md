# claude-flake

[![NixOS](https://img.shields.io/badge/NixOS-5277C3?style=flat&logo=nixos&logoColor=white)](https://nixos.org)
[![Flakes](https://img.shields.io/badge/Nix-Flakes-blue)](https://nixos.wiki/wiki/Flakes)

**Opinionated Claude Code workflow with built-in config, hooks and commands.**

Claude Code is a powerful AI coding agent from Anthropic that works in your terminal. This setup helps makes it more effective, plus development tools that work consistently across all machines.

## 🤖 What You Get

**Opinionated workflow** = The primary benefit - no decisions needed:
- Research → Plan → Implement process built into commands
- Quality checks that run automatically 
- Proven patterns from the Claude Code community
- Everything pre-configured to work together

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

# All modern dev tools are available
git status
eza -la     # Better 'ls' - shows file types and permissions clearly
rg "TODO"   # Better 'grep' - faster searching with syntax highlighting
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
- Installs Claude Code
- Configures your shell (bash/zsh) with helpful aliases
- Sets up a universal development environment

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
npm uninstall -g @anthropic-ai/claude-code

# Clean up directories
rm -rf ~/.claude ~/.config/claude-flake ~/.npm-global
```

## 🎯 What's Included

| Tool | Purpose |
|------|---------|
| **Claude Code** | AI pair programming assistant |
| **Modern CLI Tools** | bat, eza, fzf, ripgrep, jq for better terminal experience |
| **Development Tools** | git, gh, neovim, direnv |
| **Language Support** | Python 3, Node.js, and modern development tools |
| **Shell Integration** | Automatic aliases and functions |

## 🙏 Credits

Built upon the excellent work at [Veraticus/nix-config](https://github.com/Veraticus/nix-config/tree/main/home-manager/claude-code) - thank you for pioneering Claude Code configuration with Nix.

## 💡 Need Help?

**Common issues:**
- `docker: command not found` → Install Docker Desktop from docker.com
- `claude: command not found` → Restart your terminal after installation
- `Permission denied` on Docker → Add yourself to docker group: `sudo usermod -aG docker $USER` then restart terminal
- API key not working → Make sure you have credits in your Anthropic account
- "WSL not found" on Windows → Install from Microsoft Store, then restart


**What's WSL?** On Windows, you need Windows Subsystem for Linux to run Docker and development tools. Install "Ubuntu" from Microsoft Store, then use that terminal.