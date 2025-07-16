# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Claude-flake is a **Nix-based development environment orchestrator** that enhances the Claude Code AI coding assistant experience. It provides opinionated workflows, multi-language development environments, and automated code quality enforcement.

## Essential Commands

### Development Environment
```bash
# Primary CLI for development environment management
./scripts/cf                    # Auto-detect project type and enter development shell
./scripts/cf dev rust          # Enter specific language development shell
./scripts/cf dev python        # Python: poetry, black, pytest, mypy, ruff
./scripts/cf dev nodejs        # Node.js: npm/yarn/pnpm, eslint, prettier, typescript
./scripts/cf dev go            # Go: gopls, golangci-lint, gofumpt, delve
./scripts/cf dev nix           # Nix: nixfmt, statix, nil, deadnix
./scripts/cf doctor            # Diagnose environment and configuration issues
./scripts/cf update            # Update claude-flake to latest version
./scripts/cf update --local    # Update using local development version
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
nix run .#apps.x86_64-linux.home  # Deploy home-manager configuration
```

### Installation Testing
```bash
# Test installation script
bash install.sh               # Full installation
bash install.sh --dry-run     # Show what would be installed
bash install.sh --uninstall   # Remove installation
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

**Multi-Shell Architecture**: Each language environment is isolated with its own development shell containing appropriate:
- Language-specific linters and formatters
- LSP servers for editor integration
- Testing frameworks and build tools
- Security scanners

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
- **Claude Code CLI**: AI assistant integration
- **Language Toolchains**: Rust, Python, Node.js, Go, etc.

## Development Notes

- All changes must pass MegaLinter validation before commit
- NEVER prioritize backwards compatibility unless specifically told to
- Use `cf doctor` to diagnose environment issues
- Use `cf update --local` for local development testing
- Home-manager configuration is rebuilt automatically on updates