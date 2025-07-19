# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Claude-flake is a **production-quality Claude Code environment configurator** that enhances the Claude Code AI coding assistant experience. It provides sophisticated workflows, comprehensive command systems, and zero-tolerance automated code quality enforcement via MegaLinter integration.

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
# MegaLinter-powered comprehensive linting (Docker-based)
./files/hooks/smart-lint.sh    # Intelligent project-aware linting with auto-fixes
mega-linter --flavor rust      # Language-specific MegaLinter flavors
mega-linter --flavor python    # Optimized for detected project types
```

### Build and Test
```bash
# Nix flake operations
nix flake check                # Validate flake structure
nix flake show                 # Show available outputs
nix build                      # Build all packages
nix develop                    # Enter development shell
nix run --impure .#apps.x86_64-linux.home  # Deploy home-manager configuration

# Claude Code slash commands (integrated workflows)
/check                         # Zero-tolerance quality verification with mandatory fixes
/next                          # Research → Plan → Implement workflow with ultrathink mode
/commit                        # Conventional commits with emoji integration
/prompt                        # Dynamic prompt synthesis with template system
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
   - Multi-system support (x86_64-linux, aarch64-linux, aarch64-darwin, x86_64-darwin)
   - Home-manager integration for declarative user environments
   - Claude Code AI assistant integration via `claude-code-nix`
   - Cachix binary cache integration for optimized builds

2. **CLI Interface** (`scripts/cf`)
   - Auto-detects project types based on configuration files
   - Unified development environment management
   - Built-in diagnostics and update mechanisms

3. **Configuration Management**
   - Declarative user environment setup
   - Claude Code workflow integration

4. **Workflow Integration** (`workflow/`)
   - `default.nix`: Main workflow orchestration
   - `claude-config.nix`: Claude Code specific configuration and package management
   - `shell-integration.nix`: Shell environment integration with loader script

5. **Sophisticated Command System** (`files/commands/`)
   - `/check`: Zero-tolerance quality verification with parallel agent resolution
   - `/next`: Research-first implementation with ultrathink mode
   - `/commit`: Conventional commits with 115+ emoji mappings
   - `/prompt`: Template-based prompt synthesis system

6. **Advanced Quality Assurance** (`files/hooks/`)
   - `smart-lint.sh`: MegaLinter-powered multi-language linting with auto-detection
   - `ntfy-notifier.sh`: Production notification system with terminal context detection
   - Blocking hooks with exit code 2 enforcement
   - Language-specific flavor mapping (rust, python, javascript, go, java, c_cpp, cupcake)

### Key Design Patterns

**Nix-First Philosophy**: Everything is declaratively defined using Nix expressions, ensuring reproducible environments across different systems.

**Quality-First Development**: Zero-tolerance policy for linting violations with blocking hooks that prevent progression until issues are resolved.

**Language Auto-Detection**: The `cf` command and `smart-lint.sh` automatically detect project types based on:
- Rust: `Cargo.toml`/`Cargo.lock` → MegaLinter `rust` flavor
- Python: `pyproject.toml`/`requirements.txt`/`poetry.lock` → MegaLinter `python` flavor
- Node.js: `package.json`/`yarn.lock`/`package-lock.json` → MegaLinter `javascript` flavor
- Go: `go.mod`/`go.sum` → MegaLinter `go` flavor
- Java: `pom.xml`/`build.gradle` → MegaLinter `java` flavor
- C/C++: `CMakeLists.txt`/`Makefile` → MegaLinter `c_cpp` flavor
- Nix: `flake.nix`/`shell.nix`/`default.nix` → MegaLinter `cupcake` flavor with treefmt fallback

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
- **Zero-Tolerance Policy**: Exit code 2 enforcement with blocking operations until ALL issues resolved
- **MegaLinter Integration**: Docker-based comprehensive multi-language linting with optimized flavors
- **Auto-Detection & Auto-Fixing**: Project type identification with automatic code corrections (`APPLY_FIXES=all`)
- **Advanced Command Workflows**: `/check` command with parallel agent spawning for issue resolution
- **Production Standards**: Comprehensive quality checklist including security audits and performance verification

### Configuration Management
- **Home-Manager**: Declarative user environment configuration with automatic rebuilding
- **Sophisticated Command System**: Metadata-driven slash commands with strict quality requirements
- **Advanced Notification System**: Multi-terminal detection with rate limiting and retry logic
- **CI/CD Integration**: GitHub Actions with Cachix optimization and multi-system testing

## File Structure Significance

- `flake.nix`: Main entry point for Nix configuration and Claude Code integration
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

- **Nix**: Primary package manager with flakes support and multi-system architecture
- **Home-Manager**: Declarative user environment management with automatic configuration deployment
- **MegaLinter**: Comprehensive Docker-based linting with language-specific flavors and auto-fixing
- **Claude Code CLI**: Reliable AI assistant integration via `claude-code-nix` with bundled Node.js runtime
- **Cachix**: Binary cache optimization (`claude-code.cachix.org`) for faster installations
- **Language Toolchains**: Rust, Python, Node.js, Go, Java, C/C++, Nix with auto-detection

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

**MegaLinter Integration**: The `smart-lint.sh` hook now uses Docker-based MegaLinter with automatic project detection and comprehensive language support. ANSI escape sequences are prevented through:
- `TERM=dumb` environment setting
- `NO_COLOR=1` enforcement in hooks
- Docker container isolation

**Hook Update Required**: After updating the source file, reinstall hooks with:
```bash
./scripts/cf update --local  # Updates installed hooks with MegaLinter integration and NO_COLOR support
```