# Claude Code Hooks

Automated code quality checks that run after Claude Code modifies files, enforcing project standards with zero tolerance for errors.

## Hooks

### `smart-lint.sh`
Intelligent project-aware linting powered by **MegaLinter** that automatically detects language and runs comprehensive checks:

**MegaLinter Integration**:
- **Multi-language support**: Comprehensive linting via Docker-based MegaLinter
- **Auto-detection**: Rust, Python, JavaScript/TypeScript, Go, Java, C/C++, Nix projects
- **Flavor mapping**: Optimized MegaLinter flavors per project type
- **Auto-fixing**: Automatic code corrections with `APPLY_FIXES=all`
- **Performance**: Docker image caching and parallel processing

**Language-specific toolchains**:
- **Rust**: `rust` flavor (rustfmt, clippy, cargo-machete)
- **Python**: `python` flavor (black, ruff, mypy, bandit)  
- **JavaScript/TypeScript**: `javascript` flavor (eslint, prettier)
- **Go**: `go` flavor (gofmt, golangci-lint, revive)
- **Java**: `java` flavor (checkstyle, pmd, spotbugs)
- **C/C++**: `c_cpp` flavor (clang-format, cppcheck, cpplint)
- **Nix**: `cupcake` flavor with treefmt/nixfmt fallback

**Advanced Features**:
- Detects project type automatically via configuration files
- Respects project-specific Makefiles (`make lint`) when available
- Smart file filtering with configurable exclusions
- Configurable thread count and timeout management
- Exit code 2 means issues found - ALL must be fixed

#### Failure

```
> Edit operation feedback:
  - [~/.claude/hooks/smart-lint.sh]:
  🔍 Style Check - Validating code formatting...
  ────────────────────────────────────────────
  [INFO] Project type: go
  [INFO] Running Go formatting and linting...
  [INFO] Using Makefile targets

  ═══ Summary ═══
  ❌ Go linting failed (make lint)

  Found 1 issue(s) that MUST be fixed!
  ════════════════════════════════════════════
  ❌ ALL ISSUES ARE BLOCKING ❌
  ════════════════════════════════════════════
  Fix EVERYTHING above until all checks are ✅ GREEN

  🛑 FAILED - Fix all issues above! 🛑
  📋 NEXT STEPS:
    1. Fix the issues listed above
    2. Verify the fix by running the lint command again
    3. Continue with your original task
```
```

#### Success

```
> Task operation feedback:
- [~/.claude/hooks/smart-lint.sh]:
  🔍 Style Check - Validating code formatting...
  ────────────────────────────────────────────
  [INFO] Project type: go
  [INFO] Running Go formatting and linting...
  [INFO] Using Makefile targets

  👉 Style clean. Continue with your task.
```
```

By `exit 2` on success and telling it to continue, we prevent Claude from stopping after it has corrected
the style issues.

### `ntfy-notifier.sh`
Push notifications via ntfy service for Claude Code events:
- Sends alerts when Claude finishes tasks
- Includes terminal context (tmux/Terminal window name) for identification
- Requires `~/.config/claude-code-ntfy/config.yaml` with topic configuration

## Installation

Automatically installed by Nix home-manager to `~/.claude/hooks/`

## Configuration

### Global Settings
Set environment variables or create project-specific `.claude-hooks-config.sh`:

```bash
CLAUDE_HOOKS_ENABLED=false      # Disable all hooks
CLAUDE_HOOKS_DEBUG=1            # Enable debug output
```

### Per-Project Settings
Create `.claude-hooks-config.sh` in your project root:

```bash
# Language-specific options
CLAUDE_HOOKS_GO_ENABLED=false
CLAUDE_HOOKS_GO_COMPLEXITY_THRESHOLD=30
CLAUDE_HOOKS_PYTHON_ENABLED=false

# See example-claude-hooks-config.sh for all options
```

### Excluding Files
Create `.claude-hooks-ignore` in your project root using gitignore syntax:

```gitignore
vendor/**
node_modules/**
*.pb.go
*_generated.go
```

Add `// claude-hooks-disable` to the top of any file to skip hooks.

## Usage

```bash
./smart-lint.sh           # Auto-runs after Claude edits
./smart-lint.sh --debug   # Debug mode
./smart-lint.sh --fast    # Skip slow checks
```

### Exit Codes
- `0`: All checks passed ✅
- `1`: General error (missing dependencies)
- `2`: Issues found - must fix ALL

## Dependencies

Hooks work best with these tools installed:
- **Go**: `golangci-lint`
- **Python**: `black`, `ruff`
- **JavaScript**: `eslint`, `prettier`
- **Rust**: `cargo fmt`, `cargo clippy`
- **Nix**: `nixpkgs-fmt`, `alejandra`, `statix`

Hooks gracefully degrade if tools aren't installed.
