# lib/language-packages.nix - Language-specific package sets for project enhancement
#
# This module provides:
# - languagePackages: Attribute set of package lists for different languages
# - getPackagesForType: Function to get packages for a specific project type
# - getShellHook: Function to get shell initialization for a project type
{
  pkgs,
  system ? pkgs.system,
  ...
}:

let
  # Language-specific package collections for enhanced development environments
  languagePackages = {
    # Rust development tools
    rust = with pkgs; [
      rustc
      cargo
      clippy # Linter and suggestions
      rust-analyzer # LSP server
      rustfmt # Code formatter
      cargo-watch # File watcher for cargo commands
      cargo-audit # Security audit
      cargo-outdated # Check for outdated dependencies
      cargo-edit # Add/remove dependencies from CLI
      cargo-nextest # Next-generation test runner
    ];

    # Python development tools
    python = with pkgs; [
      poetry # Dependency management
      python3Packages.black # Code formatter
      python3Packages.isort # Import sorter
      python3Packages.pytest # Testing framework
      python3Packages.mypy # Static type checker
      python3Packages.ruff # Fast linter (replaces flake8, pylint)
      python3Packages.flake8 # Traditional Python linter
      python3Packages.bandit # Security linter
      python3Packages.pip-tools # Dependency management
      python3Packages.coverage # Test coverage
      pre-commit # Git hooks framework (standalone)
      python3Packages.pylsp-mypy # LSP integration for mypy
      python3Packages.python-lsp-server # LSP server
    ];

    # Node.js development tools
    nodejs = with pkgs; [
      yarn # Package manager
      pnpm # Fast package manager
      nodejs_22 # Runtime
      nodePackages.eslint # Linter
      nodePackages.prettier # Code formatter
      nodePackages.typescript # TypeScript compiler
      nodePackages.typescript-language-server # LSP server
      nodePackages.stylelint # CSS/SCSS linter
      nodePackages.markdownlint-cli # Markdown linter
      # Testing and development tools available via npm in projects
    ];

    # Go development tools
    go = with pkgs; [
      go # Compiler and runtime
      gopls # LSP server
      golangci-lint # Meta-linter with multiple checks
      gotools # Additional tools (goimports, etc.)
      delve # Debugger
      go-tools # Static analysis tools
      gotests # Generate tests
      goconvey # Testing framework with web UI
      govulncheck # Vulnerability scanner
      gosec # Security analyzer
      gofumpt # Stricter gofmt
    ];

    # Nix development tools
    nix = with pkgs; [
      nixfmt-rfc-style # Official formatter
      statix # Linter for anti-patterns
      nil # LSP server
      nix-tree # Dependency visualization
      nixpkgs-review # Review tool for nixpkgs
      deadnix # Find unused code
      nixpkgs-fmt # Alternative formatter
      nix-output-monitor # Better build output
      nix-index # File database for nixpkgs
      comma # Run programs without installing
      shellcheck # Shell script linter (for .sh files in nix projects)
    ];

    # Java development tools
    java = with pkgs; [
      jdk17 # OpenJDK 17
      maven # Build tool
      gradle # Build tool
      google-java-format # Code formatter
      checkstyle # Style checker
      # Note: spotbugs not available in nixpkgs, use findbugs or other static analysis tools
      jdt-language-server # LSP server
    ];

    # C/C++ development tools
    cpp =
      with pkgs;
      [
        gcc # Compiler
        clang # Alternative compiler
        cmake # Build system
        ninja # Build system
        gdb # Debugger
        lldb # LLVM debugger
        clang-tools # clang-format, clang-tidy
        cppcheck # Static analyzer
        ccls # LSP server
      ]
      ++
        pkgs.lib.optionals
          (pkgs.lib.hasPrefix "x86_64-linux" system || pkgs.lib.hasPrefix "aarch64-linux" system)
          [
            valgrind # Memory debugger (Linux only - not supported on macOS)
          ];

    # Shell scripting tools
    shell = with pkgs; [
      shellcheck # Shell script linter
      shfmt # Shell formatter
      bash-language-server # LSP server
      bats # Testing framework
    ];

    # Universal tools (always available baseline)
    universal = with pkgs; [
      git
      gh
      neovim
      bat
      eza
      fzf
      ripgrep
      jq
      tree
      # Quality tools that work across languages
      pre-commit # Git hooks framework
      editorconfig-core-c # EditorConfig support
      gitlint # Git commit linter
      gitleaks # Secret scanner
    ];
  };

  # Get packages for a specific project type
  # Returns: list of packages (universal packages + language-specific packages)
  getPackagesForType =
    projectType:
    let
      basePackages = languagePackages.universal;
      specificPackages = languagePackages.${projectType} or [ ];
    in
    basePackages ++ specificPackages;

  # Get shell hook commands for a specific language
  # Returns: string containing shell initialization commands
  getShellHook =
    projectType:
    {
      rust = ''
        echo "🦀 Rust development environment loaded"
        echo "Available: cargo, clippy, rust-analyzer, rustfmt, cargo-watch, cargo-audit"
        if [ -f Cargo.toml ]; then
          echo "📦 Project: $(grep '^name = ' Cargo.toml | cut -d'"' -f2)"
        fi
      '';

      python = ''
        echo "🐍 Python development environment loaded"
        echo "Available: poetry, black, isort, pytest, mypy, ruff, bandit"
        if [ -f pyproject.toml ]; then
          echo "📦 Project detected with pyproject.toml"
        elif [ -f requirements.txt ]; then
          echo "📦 Project detected with requirements.txt"
        fi
      '';

      nodejs = ''
        echo "🟢 Node.js development environment loaded"
        echo "Available: yarn, pnpm, eslint, prettier, typescript, stylelint"
        if [ -f package.json ]; then
          echo "📦 Project: $(jq -r .name package.json 2>/dev/null || echo 'unnamed')"
        fi
      '';

      go = ''
        echo "🐹 Go development environment loaded"
        echo "Available: go, gopls, golangci-lint, gofumpt, delve, gosec, govulncheck"
        if [ -f go.mod ]; then
          echo "📦 Module: $(grep '^module ' go.mod | cut -d' ' -f2)"
        fi
      '';

      nix = ''
        echo "❄️  Nix development environment loaded"
        echo "Available: nixfmt, statix, deadnix, nil, nix-tree"
        if [ -f flake.nix ]; then
          echo "📦 Nix flake project detected"
        fi
      '';

      java = ''
        echo "☕ Java development environment loaded"
        echo "Available: jdk17, maven, gradle, google-java-format, checkstyle"
        if [ -f pom.xml ]; then
          echo "📦 Maven project detected"
        elif [ -f build.gradle ] || [ -f build.gradle.kts ]; then
          echo "📦 Gradle project detected"
        fi
      '';

      cpp = ''
        echo "⚡ C/C++ development environment loaded"
        echo "Available: gcc, clang, cmake, ninja, clang-format, cppcheck"
        ${
          if (pkgs.lib.hasPrefix "x86_64-linux" system || pkgs.lib.hasPrefix "aarch64-linux" system) then
            ''echo "Available (Linux): valgrind"''
          else
            ""
        }
        if [ -f CMakeLists.txt ]; then
          echo "📦 CMake project detected"
        elif [ -f Makefile ]; then
          echo "📦 Makefile project detected"
        fi
      '';

      shell = ''
        echo "🐚 Shell development environment loaded"
        echo "Available: shellcheck, shfmt, bash-language-server, bats"
        echo "📦 Shell scripting tools ready"
      '';

      universal = ''
        echo "🌍 Universal development environment loaded"
        echo "Available: git, gh, neovim, and modern CLI tools"
      '';
    }
    .${projectType} or ''
      echo "🔧 Development environment loaded"
    '';
in
{
  inherit languagePackages getPackagesForType getShellHook;
}
