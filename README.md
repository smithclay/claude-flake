# claude-flake

[![CI](https://github.com/smithclay/claude-flake/actions/workflows/ci.yml/badge.svg)](https://github.com/smithclay/claude-flake/actions/workflows/ci.yml)
[![NixOS](https://img.shields.io/badge/NixOS-5277C3?style=flat&logo=nixos&logoColor=white)](https://nixos.org)
[![Flakes](https://img.shields.io/badge/Nix-Flakes-blue)](https://nixos.wiki/wiki/Flakes)

**Opinionated Claude Code workflow with built-in configuration, hooks, and handy tools.**

This project helps make [Claude Code](https://www.anthropic.com/claude-code), a powerful AI coding agent from Anthropic, more effective by providing essential configuration and workflow tools.

## 🤖 What you get

**Opinionated workflow**
- Research → Plan → Implement process built into commands
- Quality checks that run automatically
- Proven patterns from the Claude Code community
- Everything pre-configured to work together
- Notifications to your iOS/macOS devices with [ntfy](https://ntfy.sh/) for long-running tasks
- Handy configuration and management tools

**Plus:** Everything is managed using a [nix flake](https://nixos.wiki/wiki/flakes) for reproducible configuration.

## 📋 Requirements

**You need:**
- **Nix** package manager (installed automatically)
- **Anthropic API key** OR **Claude Pro subscription** ($20/month)
- Any coding project where you want AI help

**Supported systems:** Linux, macOS, Windows (via WSL - Windows Subsystem for Linux)

## ⚡ Quick Install (Recommended)

**One command installs everything:**

```bash
curl -sSL https://raw.githubusercontent.com/smithclay/claude-flake/main/install.sh | bash
```

This interactive installer will:
- Check your system requirements
- Install Nix package manager (if needed)
- Set up Claude Code with optimized configuration

**Then get your API key:**

1. Go to [console.anthropic.com](https://docs.anthropic.com/en/api/getting-started) for API key OR [claude.ai](https://docs.anthropic.com/en/docs/claude-code) for Pro subscription
2. Sign up and choose: API credits ($20) or Claude Pro ($20/month)
3. Create an API key (if using API) or note your Pro login
4. Run `claude` to add your credentials

## 💻 Direct System Installation

For direct installation on your system, the installer will set up Nix and claude-flake automatically:

```bash
curl -sSL https://raw.githubusercontent.com/smithclay/claude-flake/main/install.sh | bash
```

After installation, you'll have access to:
- `claude` - Claude Code CLI  
- `cf` - Claude-flake configuration tools

**Start using Claude Code:**
```bash
# Start Claude Code (you'll be prompted for your API key on first run)
claude

# Run the built in commands to help you write code. Validation hooks will run automatically.
# > /next Let's add a new API endpoint to this project...

# Configure notifications for long-running tasks
cf config ntfy init
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


## 🚀 Advanced Installation

The installer handles Nix setup automatically, but you can also install Nix manually first:

```bash
curl -L https://install.determinate.systems/nix | sh -s -- install
```

Then run the claude-flake installer.

## 🛠️ Using Claude-Flake Tools

Once installed, you can use the `cf` command for configuration and management:

```bash
# View available commands
cf help         # Shows all commands and usage instructions

# Check system status
cf status       # Shows current environment and configuration
cf doctor       # Diagnose environment and configuration issues

# Configure notifications for long-running tasks
cf config ntfy init    # Set up push notifications
cf config ntfy test    # Test notification setup

# Update claude-flake
cf update              # Update to latest version
cf update --local      # Use local development version

# Override flake source for local development
export CLAUDE_FLAKE_SOURCE=path:/path/to/local/claude-flake
```

## 🛠️ `cf` Command Reference

The `cf` command provides configuration and management tools for claude-flake:

### **Available Commands**
```bash
cf help              # Show comprehensive usage information
cf version           # Show claude-flake version and components
cf status            # Show current environment and project status
cf doctor            # Diagnose environment and configuration issues
cf update            # Update claude-flake to latest version
cf config            # Manage claude-flake configuration
```

### **Configuration Commands**
```bash
cf config ntfy init     # Interactive setup for push notifications
cf config ntfy show     # Show current notification configuration
cf config ntfy set      # Set notification topic and server
cf config ntfy test     # Send test notification
```

### **Environment Variables**
- `CLAUDE_FLAKE_SOURCE` - Override flake source (default: `github:smithclay/claude-flake`)

## 🗑️ Uninstall

Use the same installation script with the `--uninstall` flag:

```bash
curl -sSL https://raw.githubusercontent.com/smithclay/claude-flake/main/install.sh | bash -s -- --uninstall
```

This will:
- Safely remove all claude-flake components
- Offer to restore configuration backups
- Clean up all associated files and packages

**Manual removal (if needed):**
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
- `cf: command not found` → Restart your terminal after installation or check if you're in a cf shell
- `nix: command not found` → Installation may need terminal restart, check if Nix was installed correctly
- "WSL not found" on Windows → Install from Microsoft Store, then restart

**Claude Code Issues:**
- `claude: command not found` → Check `cf doctor` output and restart terminal after installation
- API key not working → Make sure you have credits in your Anthropic account, verify with `cf doctor`
- Claude hanging or slow → Check network connectivity with `cf doctor`

**cf Command Issues:**
- `cf: command not found` → Restart your terminal after installation
- Configuration not saved → Check permissions on `~/.config/claude-flake/`
- Commands not working → Run `cf doctor` to diagnose issues

**Network and Update Issues:**
- Flake not accessible → Check `cf doctor` for network connectivity and flake validation
- Update failing → Run `cf doctor` to diagnose, check internet connection
- Slow Nix operations → Check substituters in `cf doctor`

### **Diagnostic Workflow**
```bash
# Step 1: Get overview
cf doctor              # Shows all environment checks

# Step 2: Check current state  
cf status              # Shows current configuration and environment

# Step 3: Get version info
cf version             # Shows versions and dependencies

# Step 4: Test functionality
cf help                # Verify cf command works
cf config ntfy test    # Test notification setup (if configured)
```
