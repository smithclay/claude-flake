# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Claude-flake is a **Claude Code environment configurator** that enhances the Claude Code AI coding assistant experience. It provides opinionated workflows, essential configuration tools, and automated code quality enforcement.

## Essential Commands

### Configuration Management
```bash
# Primary CLI for configuration and management
./scripts/cf                    # Show help and available commands
./scripts/cf doctor            # Diagnose environment and configuration issues
./scripts/cf update            # Update claude-flake to latest version
./scripts/cf update --local    # Update using local development version
./scripts/cf config ntfy init  # Set up push notifications
./scripts/cf status            # Show current environment status
```

### Quality Assurance
```bash
# MegaLinter for multi-language linting (requires Docker)
./files/hooks/smart-lint.sh    # Smart linting hook with auto-fixes
mega-linter --flavor all       # Full linting suite (if MegaLinter installed)
```

### Build and Test
```bash
# Nix flake operations
nix flake check                # Validate flake structure
nix flake show                 # Show available outputs
nix build                      # Build all packages
nix develop                    # Enter development shell
nix run --impure .#apps.x86_64-linux.home  # Deploy home-manager configuration
```

### Installation Testing
```bash
# Test installation script
bash install.sh               # Full installation
bash install.sh --local       # Install using local development version
bash install.sh --dry-run     # Show what would be installed
bash install.sh --uninstall   # Remove installation
```

### GitHub CLI Operations
```bash
# Create and manage pull requests (use TERM=dumb to prevent ANSI color codes)
TERM=dumb gh pr create --title "feat: description" --body-file pr_body.txt
TERM=dumb gh pr edit 123 --body-file clean_body.txt
gh pr view 123                 # View pull request details
gh pr merge 123                # Merge pull request
```

### Git and Commit Best Practices

#### Clean Commit Messages
Always use `TERM=dumb` when tools might inject terminal color codes into commit messages:

```bash
# ✅ Correct: Clean commit without color codes
TERM=dumb git commit -m "feat: add local installer support

- Add --local flag for development builds
- Implement Cachix cache configuration
- Support Determinate Systems Nix setup"

# ❌ Incorrect: May include ANSI escape sequences
git commit -m "$(some-tool-with-colors --output)"

# ✅ Correct: Use TERM=dumb with command substitution
TERM=dumb git commit -m "$(TERM=dumb tool --generate-message)"
```

#### Commit Message Format
Follow conventional commit format with clear, actionable descriptions:

```
<type>(<scope>): <description>

[optional body]

[optional footer]
```

**Types**: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`
**Scope**: Component being modified (optional)
**Description**: Imperative mood, lowercase, no period

```bash
# Examples of well-formed commit messages
git commit -m "feat(installer): add --local flag for development builds"
git commit -m "fix(cachix): resolve untrusted substituter warnings"
git commit -m "docs(readme): update installation instructions"
git commit -m "refactor(nix): simplify flake configuration structure"
```

#### Avoiding Color Code Contamination
Common sources of ANSI escape sequences in commits:

1. **Tool output**: Linters, formatters, test runners with colored output
2. **Shell prompts**: Complex PS1 configurations
3. **Piped commands**: Tools that detect TTY and add colors
4. **Environment variables**: FORCE_COLOR, NO_COLOR settings

**Prevention strategies**:
```bash
# Set environment for clean output
export TERM=dumb
export NO_COLOR=1
unset FORCE_COLOR

# Use in git hooks and automated scripts
#!/usr/bin/env bash
export TERM=dumb
git commit -m "automated: update dependencies"

# Clean existing contaminated commits (if needed)
git log --oneline | grep -E '\[[0-9;]+m' # Find contaminated commits
git rebase -i HEAD~N # Interactive rebase to clean up
```

#### Integration with Development Tools
```bash
# MegaLinter with clean output
TERM=dumb mega-linter --flavor all > lint-report.txt

# GitHub CLI operations
TERM=dumb gh pr create --title "$(git log -1 --pretty=%s)"

# Automated deployment
TERM=dumb nix run --impure .#apps.x86_64-linux.home 2>&1 | tee deploy.log
```

## Architecture Overview

### Core Components

1. **Nix Flake System** (`flake.nix`)
   - Multi-system support (x86_64-linux, aarch64-linux)
   - Dynamic development shells for 9 languages
   - Home-manager integration for declarative user environments

2. **CLI Interface** (`scripts/cf`)
   - Auto-detects project types based on configuration files
   - Unified development environment management
   - Built-in diagnostics and update mechanisms

3. **Library Layer** (`lib/`)
   - `default.nix`: Core development shell creation functions
   - `language-packages.nix`: Language-specific tooling packages

4. **Workflow Integration** (`workflow/`)
   - `default.nix`: Main workflow orchestration
   - `dev-environment.nix`: Development environment configuration
   - `claude-config.nix`: Claude Code specific configuration
   - `shell-integration.nix`: Shell environment integration

5. **Quality Assurance** (`files/hooks/`)
   - `smart-lint.sh`: Automated linting with MegaLinter
   - Git hooks for code quality enforcement
   - Notification system via ntfy

### Key Design Patterns

**Nix-First Philosophy**: Everything is declaratively defined using Nix expressions, ensuring reproducible environments across different systems.

**Quality-First Development**: Zero-tolerance policy for linting violations with blocking hooks that prevent progression until issues are resolved.

**Language Auto-Detection**: The `cf` command automatically detects project types based on:
- Rust: `Cargo.toml`/`Cargo.lock`
- Python: `pyproject.toml`/`requirements.txt`/`poetry.lock`
- Node.js: `package.json`/`yarn.lock`/`package-lock.json`
- Go: `go.mod`/`go.sum`
- Nix: `flake.nix`/`shell.nix`/`default.nix`

**Nix-First Philosophy**: Everything is declaratively defined using Nix expressions, ensuring reproducible environments across different systems.

**Claude Code Integration**: Uses `claude-code-nix` for reliable, Nix-native Claude CLI installation with:
- Bundled Node.js runtime eliminating version conflicts
- Automatic daily updates from upstream repository
- Stable binary paths and persistent configuration
- Pre-built binaries via Cachix for faster installation

## Development Workflow

### Research → Plan → Implement
This project enforces a structured development methodology through Claude Code integration:

1. **Research**: Explore codebase and understand existing patterns
2. **Plan**: Create detailed implementation plan with validation checkpoints
3. **Implement**: Execute plan with automated quality checks

### Quality Enforcement
- **MegaLinter Integration**: Comprehensive multi-language linting via Docker
- **Language-Specific Tools**: Each shell includes appropriate linters (rustfmt, black, eslint, gofmt, etc.)
- **Blocking Hooks**: `smart-lint.sh` prevents commits until all issues are resolved
- **Auto-Fixing**: Many linting issues are automatically corrected

### Configuration Management
- **Home-Manager**: Declarative user environment configuration
- **Claude Code Integration**: Custom commands and workflow enforcement
- **Notification System**: Push notifications via ntfy for long-running tasks

## File Structure Significance

- `flake.nix`: Main entry point defining all development environments
- `scripts/cf`: Primary user interface for environment management
- `lib/`: Shared utilities and language package definitions
- `workflow/`: Home-manager modules for user environment setup
- `files/claude/`: Claude Code configuration and workflow guidance
- `files/hooks/`: Git hooks and quality enforcement scripts
- `install.sh`: Comprehensive installation script with Nix setup
- `.mega-linter.yml`: Multi-language linting configuration

## Testing Strategy

- **Integration Testing**: CLI commands and shell environments
- **End-to-End Validation**: Complete development workflows
- **Quality Assurance**: Automated linting and formatting checks
- **System Testing**: Installation and update procedures

## Key Dependencies

- **Nix**: Primary package manager with flakes support
- **Home-Manager**: User environment management
- **MegaLinter**: Multi-language linting (Docker-based)
- **Claude Code CLI**: AI assistant integration via `claude-code-nix`
- **Language Toolchains**: Rust, Python, Node.js, Go, etc.

## Development Notes

- All changes must pass MegaLinter validation before commit
- NEVER prioritize backwards compatibility unless specifically told to
- Use `cf doctor` to diagnose environment issues
- Use `cf update --local` for local development testing
- Home-manager configuration is rebuilt automatically on updates

## Known Limitations and Workarounds

### ANSI Escape Sequence Contamination

**Problem**: Git commit messages may contain ANSI escape sequences (`[38;5;231m`, `[0m`) despite using `TERM=dumb`, due to recent Git vulnerabilities (CVE-2024-50349, CVE-2024-52005) and tool chain contamination.

**Solution**: Multi-layer prevention strategy implemented:

1. **Git Configuration** (Already configured globally):
   ```bash
   git config --global color.ui never
   git config --global core.pager ""
   ```

2. **Environment Variables** (Set only during commits):
   ```bash
   NO_COLOR=1 TERM=dumb git commit -m "clean message"
   ```

**Current Git Version**: 2.50.0 (includes ANSI vulnerability patches)

**Hook Update Required**: After updating the source file, reinstall hooks with:
```bash
./scripts/cf update --local  # Updates installed hooks with NO_COLOR support
```