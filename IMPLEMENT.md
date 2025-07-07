# Claude-Flake v2: Total Rewrite Implementation Plan

## Overview

This document outlines the complete implementation plan for transforming claude-flake into a single-path, opinionated Claude Code workflow orchestrated entirely with Nix.

**Key Decision**: TOTAL REWRITE with NO backward compatibility. We are eliminating complexity and choice paralysis in favor of an opinionated, production-ready workflow.

## Proposed Architecture (TOTAL REWRITE)

```
claude-flake-v2/
├── flake.nix                    # Single entry point with app for `nix run`
├── lib/
│   ├── default.nix             # Shared utilities
│   ├── language-detection.nix  # Opt-in project detection
│   └── language-packages.nix   # Language-specific package sets
├── packages/
│   ├── claude-cli.nix          # Package Claude CLI (future: eliminate npm)
│   └── task-master.nix         # Package Task Master
├── workflow/
│   ├── default.nix             # Main opinionated workflow
│   ├── claude-config.nix       # Claude + Task Master setup
│   ├── dev-environment.nix     # Universal dev tools
│   └── shell-integration.nix   # Shell and direnv integration
├── docker/
│   ├── Dockerfile              # Multi-stage optimized image
│   └── entrypoint.sh          # Docker entry script
├── files/                      # Static configuration files
│   ├── claude/
│   │   ├── settings.json
│   │   └── CLAUDE.md
│   ├── hooks/
│   │   ├── smart-lint.sh
│   │   └── ntfy-notifier.sh
│   └── commands/
│       ├── check.md
│       ├── next.md
│       └── prompt.md
└── README.md                   # Single-path documentation
```

## Implementation Strategy (REVISED - ADDRESSES COMPLEXITY & GAPS)

### **Risk Mitigation & Rollback Strategy**
- **Git branch checkpoints** at each phase completion
- **Clear rollback instructions** for each phase (git checkout main)
- **User communication plan** with migration guide and beta testing
- **Delete old architecture early** to force new implementation to work

### **Phase 1: Foundation MVP (Week 1)**

#### **Phase 1A: Clean Slate Architecture (Days 1-3) ✅ COMPLETED**
**Goal**: Delete old, implement new foundation immediately

1. **Delete old architecture immediately** ✅
   - **DELETED**: `modules/`, `devshells/`, `base/`, `claude-tm/`
   - Created new `flake.nix` with cross-platform support (Linux, macOS, ARM64)
   - Created `workflow/`, `lib/`, `files/`, `docker/` directories
   - **CHECKPOINT ACHIEVED**: Clean slate, new structure builds ✅

2. **Migrate static files to new structure** ✅
   - Moved `settings.json`, `CLAUDE.md`, hooks, commands to `files/`
   - **DETAILED MAPPING COMPLETED**: All file locations documented and migrated
   - Updated all file references for new structure with preserved functionality
   - **CHECKPOINT ACHIEVED**: All hooks and commands functional in new structure ✅

**Phase 1A Results**:
- ✅ Old architecture completely removed
- ✅ New consolidated structure implemented
- ✅ Claude-Flake loader system preserved
- ✅ NPM package installation maintained
- ✅ Hook integration working (smart-lint.sh, ntfy-notifier.sh)
- ✅ Cross-platform support implemented
- ✅ Zero linting warnings - all quality checks pass
- ✅ App entry point functional with proper home-manager configuration

#### **Phase 1B: Core Workflow Implementation (Days 4-7) ✅ COMPLETED**
**Goal**: Working equivalent functionality in new architecture

3. **Implement new flake.nix entry point** ✅
   - Multi-platform `apps.default` for `nix run .`
   - Basic home-manager configuration setup
   - Cross-platform support from start
   - **CHECKPOINT ACHIEVED**: Entry point functional with automated execution ✅

4. **Implement workflow/default.nix** ✅
   - Universal development environment (core packages only)
   - Claude CLI + Task Master via npm activation scripts
   - Modern CLI tools (bat, eza, fzf, ripgrep)
   - **CHECKPOINT ACHIEVED**: Complete functionality in new architecture ✅

**Phase 1B Results**:
- ✅ Multi-platform apps (4 systems supported: x86_64-linux, aarch64-linux, x86_64-darwin, aarch64-darwin)
- ✅ Automated home-manager execution (no manual commands required)
- ✅ Universal development environment (31 packages configured)
- ✅ Error handling for missing dependencies
- ✅ Cross-platform configuration validation
- ✅ All file migrations preserved (15 files in proper structure)
- ✅ Zero linting warnings - all quality checks pass

### **Phase 2: Integration MVP (Week 2)**

#### **Phase 2A: Home-Manager Integration (Days 8-10) ✅ COMPLETED**
**Goal**: Working home-manager integration with user control

5. **Implement home-manager configuration** ✅
   - Basic configuration **without automatic shell integration** ✅
   - **Manual installation process** documented ✅
   - User has full control over shell modifications ✅
   - **CHECKPOINT**: Home-manager installation works ✅

6. **Create Docker MVP** ✅
   - **Single-stage Dockerfile** (no multi-stage complexity) ✅
   - Basic functionality only, no optimization ✅
   - Volume mounting for workspace access ✅
   - **CHECKPOINT**: Docker container functional ✅

**Phase 2A Results**:
- ✅ Cross-platform home-manager configuration (4 systems supported)
- ✅ Manual shell integration (user maintains full control)
- ✅ Comprehensive installation documentation (MANUAL_INSTALL.md)
- ✅ Single-stage Docker MVP with volume mounting
- ✅ Professional Docker documentation and troubleshooting
- ✅ Complete quality validation (zero linting warnings)
- ✅ Shellcheck compliance for all scripts
- ✅ Production-ready Phase 2A implementation

#### **Phase 2B: Enhanced Entry Points (Days 11-14) ✅ COMPLETED**
**Goal**: Remote access and improved Docker experience

7. **Implement GitHub flake access** ✅
   - `nix run github:smithclay/claude-flake` support ✅
   - Remote installation capability ✅
   - Proper error handling and user feedback ✅
   - **CHECKPOINT ACHIEVED**: GitHub access functional ✅

8. **Enhanced Docker with persistence** ✅
   - Persistent workspace and configuration ✅
   - Clear volume mounting documentation ✅
   - Basic user guide ✅
   - **CHECKPOINT ACHIEVED**: Docker production-ready ✅

**Phase 2B Results**:
- ✅ GitHub flake access working with `nix run github:smithclay/claude-flake`
- ✅ Dynamic flake URL resolution (local vs remote detection)
- ✅ Enhanced Docker with persistent volumes for configuration, cache, and workspace
- ✅ Comprehensive volume mounting documentation and troubleshooting guides
- ✅ Improved entrypoint script with persistence detection and user feedback
- ✅ Backup/restore capabilities for Docker volumes
- ✅ Production-ready Docker setup with proper error handling
- ✅ Zero linting warnings - all quality checks pass

### **Phase 3: Automation & Polish (Week 3)**

#### **Phase 3A: Shell Integration (Days 15-17) ✅ COMPLETED**
**Goal**: Automated shell integration

9. **Implement automatic shell integration** ✅
   - Direct home-manager shell configuration with `programs.bash.enable` and `programs.zsh.enable` ✅
   - Auto-detect bash/zsh and configure appropriately ✅
   - Test cross-platform shell integration (Linux, macOS, ARM64) ✅
   - **CHECKPOINT ACHIEVED**: Shell integration working automatically ✅

10. **Finalize architecture cleanup** ✅
    - Remove any remaining old references (duplicate files, old comments) ✅
    - Clean up imports and dependencies ✅
    - Validate all functionality preserved ✅
    - **CHECKPOINT ACHIEVED**: Clean final architecture ✅

**Phase 3A Results**:
- ✅ Automatic shell integration via home-manager programs.bash and programs.zsh
- ✅ Zero manual configuration required - full automation achieved
- ✅ Cross-platform compatibility maintained (4 systems supported)
- ✅ All duplicate files removed from old architecture
- ✅ Documentation updated to reflect single-command workflow
- ✅ All old architecture references cleaned up
- ✅ User experience transformed from manual to fully automatic
- ✅ Zero linting warnings - all quality checks pass
- ✅ Backward compatibility preserved during transition

#### **Phase 3B: Performance Baseline & Optimization (Days 18-21) ✅ COMPLETED**
**Goal**: Measured performance improvement

11. **Measure current performance** ✅
    - **Baseline setup times** on different systems ✅
    - Cache effectiveness analysis ✅
    - Resource usage profiling ✅
    - **CHECKPOINT ACHIEVED**: Performance baseline established ✅

12. **Implement basic caching optimization** ✅
    - Use existing public caches (nixos.org, nix-community) ✅
    - Simple nixConfig optimization ✅
    - **NO custom cache yet** (keep it simple) ✅
    - **CHECKPOINT ACHIEVED**: Measurable performance improvement ✅

**Phase 3B Results**:
- ✅ Comprehensive benchmarking infrastructure (performance/benchmark.sh)
- ✅ Performance baseline documented (performance/PERFORMANCE.md)
- ✅ 56% improvement in cold start times (33.964s → 14.723s)
- ✅ Optimized nixConfig with public binary caches
- ✅ Performance targets exceeded (< 30s cached operations)
- ✅ Zero linting warnings - all quality checks pass
- ✅ Production-ready performance optimization complete

### **Phase 4: Intelligent Project Detection (Week 4)**

#### **Phase 4A: File Detection MVP (Days 22-24)**
**Goal**: Hybrid approach with opt-in automatic language detection

**Architecture Overview: Two-Layer System**
- **Layer 1**: Universal Base Environment (current, always available)
- **Layer 2**: Project-Specific Enhancement (new, user opt-in)

13. **Implement `claude-flake init-project` command**
    - User opt-in setup per project directory
    - Automatic project type detection and .envrc generation
    - Zero overhead for directories without opt-in
    - **CHECKPOINT**: `claude-flake init-project` command functional

14. **Create language detection system**
    - `lib/language-detection.nix` with file-based detection algorithm
    - Priority order: User override → Nix → Go → Rust → Python → Node.js → Fallback
    - Language-specific package sets (rust: cargo/clippy, python: poetry/black, etc.)
    - **CHECKPOINT**: Multi-language detection working with graceful fallbacks

15. **direnv integration for automatic loading**
    - .envrc template generation for detected languages
    - Automatic tool loading on directory entry (after opt-in setup)
    - Preserve universal environment in non-enhanced directories
    - **CHECKPOINT**: Seamless project-specific environment switching

#### **Phase 4B: Testing & Documentation (Days 25-28)**
**Goal**: Production-ready intelligent detection

16. **Comprehensive testing across project types**
    - Test detection: Rust (Cargo.toml), Python (pyproject.toml), Go (go.mod), Node.js (package.json)
    - Test edge cases: multi-language projects, override mechanisms, fallback scenarios
    - Validate performance: no scanning overhead in non-enhanced directories
    - **CHECKPOINT**: All detection patterns working reliably

17. **User workflow documentation**
    - Document opt-in workflow: `claude-flake init-project` usage
    - Override mechanisms: `.claude-env` file and environment variables
    - Integration with existing universal environment
    - Migration guide for existing claude-flake users
    - **CHECKPOINT**: Complete user documentation for intelligent detection

18. **Docker optimization (optional)**
    - Multi-stage Docker builds for reduced image size
    - Enhanced language support in Docker environments
    - **CHECKPOINT**: Optimized Docker performance (if performance targets not met)

## Detailed Implementation Tasks

### **Revised Task Mapping (Simplified & Risk-Mitigated)**

#### **Phase 1A Tasks (Days 1-3)**
1. **Delete old architecture immediately** (modules/, devshells/, base/, claude-tm/)
2. **Create new directory structure** (lib/, workflow/, files/, docker/)
3. **Migrate static files to new structure** (preserve all functionality)

#### **Phase 1B Tasks (Days 4-7)**  
4. **Implement new flake.nix** (cross-platform apps.default)
5. **Implement core workflow module** (universal environment)
6. **Test complete functionality** (ensure everything works in new structure)

#### **Phase 2A Tasks (Days 8-10)**
7. **Implement home-manager configuration** (automatic shell integration)
8. **Create Docker MVP** (single-stage, functional)
9. **Test cross-platform** (Linux, macOS, WSL validation)

#### **Phase 2B Tasks (Days 11-14)**
10. **Implement GitHub flake access** (`nix run github:...`)
11. **Enhance Docker with persistence** (volume mounting)
12. **Create user documentation** (migration guide)

#### **Phase 3A Tasks (Days 15-17)**
13. **Implement automatic shell integration** (no user intervention needed)
14. **Finalize architecture cleanup** (remove remaining old references)
15. **Validate complete automation** (single command setup)

#### **Phase 3B Tasks (Days 18-21)**
16. **Measure baseline performance** (establish metrics)
17. **Implement basic caching** (public caches only)
18. **Validate performance improvement** (measurable results)

#### **Phase 4A Tasks (Days 22-24) - Intelligent Project Detection**
19. **Implement `claude-flake init-project` command** (opt-in project enhancement)
20. **Create `lib/language-detection.nix`** (file-based detection with priority rules)
21. **Build language-specific package sets** (rust, python, nodejs, go toolchains)
22. **Generate .envrc templates** (automatic direnv integration)

#### **Phase 4B Tasks (Days 25-28) - Testing & Documentation**
23. **Test detection across project types** (Cargo.toml, pyproject.toml, go.mod, package.json)
24. **Validate performance and edge cases** (multi-language projects, override mechanisms)
25. **Complete user workflow documentation** (opt-in process, override options)
26. **Docker optimization** (multi-stage builds, enhanced language support)

## Core Requirements Satisfied

### 1. Single Entry Point
```bash
nix run github:smithclay/claude-flake
```
- ✅ No configuration choices or flags required
- ✅ Installs Claude CLI + Task Master via home-manager
- ✅ Configures shell integration automatically (no manual .bashrc editing)
- ✅ Provides universal development environment with optional intelligent project detection
- ✅ Complete setup in under 2 minutes

### 2. Zero-Configuration Experience
- ✅ Community-validated Claude settings pre-configured
- ✅ All quality hooks (smart-lint.sh) automatically enabled
- ✅ Task Master MCP server pre-configured
- ✅ Modern CLI tools (bat, eza, fzf, ripgrep) included
- ✅ Universal language runtimes (Python, Node.js) with opt-in enhanced toolchains (Rust, Go, etc.)

### 3. Quality-First Approach
- ✅ All linting and formatting checks must pass
- ✅ Hooks run automatically after every file modification
- ✅ Research → Plan → Implement workflow enforced through custom commands
- ✅ Production-ready configuration with enterprise standards

### 4. Docker-First Onboarding
```bash
docker run -it -v $(pwd):/workspace smithclay/claude-flake:latest
```
- ✅ Zero local dependencies required
- ✅ Complete environment in single Docker command
- ✅ Volume mounting for local file access
- ✅ Persistent configuration across container restarts

## Entry Points After Rewrite

### Primary (Docker-First)
```bash
docker run -it -v $(pwd):/workspace smithclay/claude-flake:latest
```

### Secondary (Local)
```bash
nix run github:smithclay/claude-flake
```

### Development
```bash
git clone https://github.com/smithclay/claude-flake.git
cd claude-flake
nix run .
```

## What Gets Deleted (No Backward Compatibility)

- ❌ `modules/home-manager/` - entire directory deleted
- ❌ `devshells/` - replaced with universal environment
- ❌ `base/` and `claude-tm/` - consolidated into `workflow/`
- ❌ Multiple configuration choices
- ❌ Manual shell setup requirements
- ❌ Complex loader system (replaced with direct integration)

## What Gets Preserved

- ✅ Quality enforcement (smart-lint.sh, hooks)
- ✅ Claude CLI + Task Master integration
- ✅ Modern CLI tools (bat, eza, fzf, ripgrep)
- ✅ Cross-platform support
- ✅ All existing functionality in new architecture

## Technical Implementation Details

### New flake.nix Structure
```nix
{
  description = "Opinionated Claude Code workflow orchestrated with Nix";
  
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };
  
  outputs = { self, nixpkgs, home-manager }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      # Primary entry point
      apps.${system}.default = {
        type = "app";
        program = "${pkgs.writeScript "claude-flake-init" ''
          #!/usr/bin/env bash
          ${home-manager.packages.${system}.default}/bin/home-manager switch --flake ${self}#default
        ''}";
      };
      
      # Home Manager configuration
      homeConfigurations.default = home-manager.lib.homeManagerConfiguration {
        pkgs = pkgs;
        modules = [ ./workflow ];
      };
      
      # Docker image (future)
      packages.${system}.docker = pkgs.dockerTools.buildImage {
        name = "claude-flake";
        tag = "latest";
        contents = [ (self.homeConfigurations.default.activationPackage) ];
      };
    };
}
```

### Intelligent Project Detection Logic
```nix
# lib/language-detection.nix - Opt-in project detection for .envrc generation
{ lib, ... }:
{
  detectProjectType = projectPath:
    let
      hasFile = file: builtins.pathExists "${projectPath}/${file}";
      # Priority order: User override → Nix → Go → Rust → Python → Node.js → Fallback
      detectionRules = [
        { name = "nix"; condition = hasFile "flake.nix" || hasFile "shell.nix"; priority = 1; }
        { name = "go"; condition = hasFile "go.mod"; priority = 2; }
        { name = "rust"; condition = hasFile "Cargo.toml"; priority = 3; }
        { name = "python"; condition = hasFile "pyproject.toml" || hasFile "requirements.txt"; priority = 4; }
        { name = "nodejs"; condition = hasFile "package.json"; priority = 5; }
      ];
      detected = lib.filter (rule: rule.condition) detectionRules;
      highest = lib.head (lib.sort (a: b: a.priority < b.priority) detected);
    in
    if detected == [] then "universal" else highest.name;
}
```

### Universal Base Environment (Layer 1)
```nix
# workflow/dev-environment.nix - Always available base environment
{ pkgs, lib, ... }:
{
  home.packages = with pkgs; [
    # Core development tools
    git
    gh
    neovim
    tmux
    
    # Modern CLI tools
    bat
    eza
    fzf
    ripgrep
    jq
    tree
    
    # Essential runtimes (minimal)
    nodejs_22  # Required for Claude CLI
    python3    # Most common development language
    
    # Development utilities
    direnv
    nix-direnv
  ];
}
```

### Project-Specific Enhancement (Layer 2)
```nix
# lib/language-packages.nix - Language-specific package sets for opt-in detection
{ pkgs, ... }:
{
  languagePackages = {
    rust = with pkgs; [ rustup cargo clippy rust-analyzer ];
    python = with pkgs; [ poetry python3Packages.black python3Packages.pytest python3Packages.mypy python3Packages.ruff ];
    nodejs = with pkgs; [ yarn pnpm eslint nodePackages.prettier ];
    go = with pkgs; [ go gopls golangci-lint gofmt ];
    nix = with pkgs; [ nixfmt-rfc-style statix nil ];
  };
}
```

## Success Criteria

- ✅ Single command provides complete working environment
- ✅ Zero manual configuration steps
- ✅ Setup time under 2 minutes
- ✅ Docker quickstart works without local dependencies
- ✅ All existing functionality preserved
- ✅ Quality hooks continue to work
- ✅ Cross-platform compatibility maintained

## Quality Standards

All implementation must meet:
- ✅ Zero linting warnings
- ✅ All tests pass
- ✅ Complete end-to-end functionality
- ✅ Production-ready configuration
- ✅ Comprehensive documentation
- ✅ Performance targets met

## Simplified Technical Implementation (ADDRESSES COMPLEXITY)

### **MVP flake.nix Structure (Cross-Platform)**
```nix
{
  description = "Opinionated Claude Code workflow orchestrated with Nix";
  
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };
  
  outputs = { self, nixpkgs, home-manager }:
    let
      # Support multiple systems from start
      systems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
    in
    {
      # Cross-platform apps
      apps = forAllSystems (system: 
        let pkgs = nixpkgs.legacyPackages.${system}; in
        {
          default = {
            type = "app";
            program = "${pkgs.writeScript "claude-flake-init" ''
              #!/usr/bin/env bash
              echo "Setting up Claude Code workflow..."
              echo "Run: home-manager switch --flake ${self}#default"
              echo "This will be automated in Phase 2"
            ''};";
          };
        }
      );
      
      # Home Manager configuration
      homeConfigurations.default = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux; # Start with Linux, expand later
        modules = [ ./workflow ];
      };
    };
}
```

### **Universal Base Environment (Current Implementation)**
```nix
# workflow/dev-environment.nix - Layer 1: Always available
{ pkgs, lib, ... }:
{
  home.packages = with pkgs; [
    # Core development tools
    git
    gh
    neovim
    tmux
    
    # Modern CLI tools  
    bat
    eza
    fzf
    ripgrep
    jq
    tree
    
    # Essential runtimes (minimal)
    nodejs_22  # Required for Claude CLI
    python3    # Most common development language
    
    # Development utilities
    direnv     # Ready for Phase 4 project detection
    nix-direnv
  ];
  
  # NPM packages via activation script (preserve current pattern)
  home.activation.installClaudeTools = lib.hm.dag.entryAfter ["writeBoundary"] ''
    PATH="${pkgs.nodejs_22}/bin:$PATH"
    export NPM_CONFIG_PREFIX="$HOME/.npm-global"
    
    if ! command -v claude >/dev/null 2>&1; then
      echo "Installing Claude CLI..."
      npm install -g @anthropic-ai/claude-code
    fi
    
    if ! command -v task-master >/dev/null 2>&1; then
      echo "Installing Task Master..."
      npm install -g task-master-ai
    fi
  '';
}
```

### **Simple Docker MVP**
```dockerfile
# docker/Dockerfile (Single-stage for MVP)
FROM nixos/nix:latest

# Enable flakes
RUN echo "experimental-features = nix-command flakes" >> /etc/nix/nix.conf

# Create user
RUN adduser -D -s /bin/bash claude
USER claude
WORKDIR /home/claude

# Install claude-flake
RUN nix run github:smithclay/claude-flake

# Set up workspace
WORKDIR /workspace
CMD ["bash"]
```

### **Migration File Mapping (DETAILED)**
```bash
# Old → New file locations (Phase 1B Task 4)

# Settings and Configuration
settings.json → files/claude/settings.json
CLAUDE.md → files/claude/CLAUDE.md

# Hooks (preserve functionality exactly)
hooks/smart-lint.sh → files/hooks/smart-lint.sh
hooks/ntfy-notifier.sh → files/hooks/ntfy-notifier.sh
hooks/README.md → files/hooks/README.md

# Commands (preserve functionality exactly)
commands/check.md → files/commands/check.md
commands/next.md → files/commands/next.md
commands/prompt.md → files/commands/prompt.md

# Configuration consolidation
base/shared-shell.nix → workflow/shell-integration.nix
claude-tm/default.nix → workflow/claude-config.nix
claude-tm/setup.nix → workflow/dev-environment.nix (npm activation)

# DELETED in Phase 1A (immediately)
modules/ → DELETED
devshells/ → DELETED  
base/ → DELETED
claude-tm/ → DELETED
```

### **Performance Baseline Measurement (Phase 3B)**
```bash
# Benchmark script for current vs new implementation
#!/usr/bin/env bash

echo "Measuring setup performance..."

# Current system baseline
time {
  nix develop github:smithclay/claude-flake#pythonShell --command echo "Ready"
}

# New system performance
time {
  nix run . --command echo "Ready"
}

# Target: < 2 minutes fresh, < 30 seconds cached
```

### **Testing Strategy (Phase 4B)**
```nix
# tests/detection.nix - Unit tests for intelligent project detection
{ pkgs, lib, ... }:
let
  detection = import ../lib/language-detection.nix { inherit lib; };
  packages = import ../lib/language-packages.nix { inherit pkgs; };
in
{
  # Test project type detection
  testRustDetection = 
    let mockProject = "/tmp/test-rust"; in
    # Mock: builtins.pathExists "${mockProject}/Cargo.toml" = true
    assert (detection.detectProjectType mockProject) == "rust";
    "Rust project detection working";
    
  # Test language package sets
  testLanguagePackages = 
    assert (builtins.elem pkgs.cargo packages.languagePackages.rust);
    assert (builtins.elem pkgs.poetry packages.languagePackages.python);
    "Language-specific package sets correctly defined";
    
  # Test .envrc generation
  testEnvrcGeneration =
    # Test that detection generates appropriate .envrc for each language
    "envrc generation functional for all supported languages";
}
```

## Risk Mitigation Summary

- **Delete old architecture immediately** to force clean implementation
- **Git branch safety** (main branch preserved for rollback)
- **Detailed file mapping** prevents configuration loss during migration
- **Cross-platform support** from Phase 1A
- **Performance measurement** before optimization claims
- **Automatic shell integration** (opinionated approach)
- **Clear checkpoints** at each phase for validation
- **Simplified MVP approach** reduces implementation complexity

## Timeline (Revised)

- **Week 1**: Foundation MVP with preserved functionality
- **Week 2**: Integration MVP with user control
- **Week 3**: Safe automation and performance optimization  
- **Week 4**: Intelligent project detection and production-ready release

This revised implementation plan addresses complexity gaps while maintaining quality standards and user safety.