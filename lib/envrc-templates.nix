# lib/envrc-templates.nix - .envrc template generation for project types
{ lib, ... }:

{
  # Generate .envrc content for a specific project type
  generateEnvrc =
    projectType: flakeUrl:
    let
      templates = {
        rust = ''
          # Enhanced development environment
          # Rust development environment with enhanced tooling

          use flake ${flakeUrl}#rust-dev --accept-flake-config

          # Rust-specific environment variables
          export RUST_BACKTRACE=1
          export CARGO_HOME="$PWD/.cargo"

          # Load additional tools if available
          if command -v rust-analyzer >/dev/null 2>&1; then
            export PATH="$PATH:$(dirname $(which rust-analyzer))"
          fi
        '';

        python = ''
          # Enhanced development environment
          # Python development environment with enhanced tooling

          use flake ${flakeUrl}#python-dev --accept-flake-config

          # Python-specific environment variables
          export PYTHONPATH="$PWD:$PYTHONPATH"
          export PIP_REQUIRE_VIRTUALENV=true

          # Poetry configuration
          if [ -f pyproject.toml ]; then
            export POETRY_VENV_IN_PROJECT=true
          fi
        '';

        nodejs = ''
          # Enhanced development environment
          # Node.js development environment with enhanced tooling

          use flake ${flakeUrl}#nodejs-dev --accept-flake-config

          # Node.js-specific environment variables
          export NODE_ENV=development
          export NPM_CONFIG_PREFIX="$PWD/.npm-global"
          export PATH="$PWD/node_modules/.bin:$PATH"

          # Detect package manager
          if [ -f yarn.lock ]; then
            echo "Using Yarn package manager"
          elif [ -f pnpm-lock.yaml ]; then
            echo "Using pnpm package manager"
          fi
        '';

        go = ''
          # Enhanced development environment
          # Go development environment with enhanced tooling

          use flake ${flakeUrl}#go-dev --accept-flake-config

          # Go-specific environment variables
          export GOPATH="$PWD/.go"
          export GOPROXY=https://proxy.golang.org,direct
          export GOSUMDB=sum.golang.org
          export CGO_ENABLED=1

          # Create GOPATH if it doesn't exist
          mkdir -p "$GOPATH"
        '';

        nix = ''
          # Enhanced development environment
          # Nix development environment with enhanced tooling

          use flake ${flakeUrl}#nix-dev --accept-flake-config

          # Nix-specific environment variables
          export NIX_PATH="nixpkgs=channel:nixos-unstable"

          # Enable experimental features for development
          export NIX_CONFIG="experimental-features = nix-command flakes"

          # Detect project type
          if [ -f flake.nix ]; then
            echo "Nix flake project detected"
            use flake . --accept-flake-config
          fi
        '';

        universal = ''
          # Enhanced development environment
          # Universal development environment

          use flake ${flakeUrl}#universal-dev --accept-flake-config

          # Universal environment variables
          export EDITOR=''${EDITOR:-nvim}
          export PAGER=''${PAGER:-bat}

          # Load project-specific configuration if available
          if [ -f .claude-env ]; then
            source .claude-env
          fi
        '';
      };
    in
      templates.${projectType} or templates.universal;

  # Generate devShell configuration for flake.nix integration
  generateDevShell =
    projectType: pkgs:
    let
      languagePackages = import ./language-packages.nix { inherit pkgs; };
      packages = languagePackages.getPackagesForType projectType;
      shellHook = languagePackages.getShellHook projectType;
    in
    ''
      ${projectType}-dev = pkgs.mkShell {
        buildInputs = with pkgs; ${
          lib.concatStringsSep " " (map (pkg: pkg.pname or (toString pkg)) packages)
        };

        shellHook = '''
          ${shellHook}

          # Project-specific setup
          if [ -f .claude-env ]; then
            echo "Loading project overrides from .claude-env"
            source .claude-env
          fi
        ''';
      };
    '';

  # Generate complete .envrc with error handling
  generateCompleteEnvrc =
    projectType: flakeUrl:
    let
      baseEnvrc = generateEnvrc projectType flakeUrl;
    in
    ''
      #!/usr/bin/env bash
      # Claude-Flake Enhanced Project Environment
      # Generated for: ${projectType} project
      # Flake source: ${flakeUrl}

      ${baseEnvrc}

      # Error handling and fallback
      if ! command -v direnv >/dev/null 2>&1; then
        echo "⚠️  direnv not found. Install with: nix profile install nixpkgs#direnv"
        exit 1
      fi

      # Success message
      echo "✅ Enhanced ${projectType} environment loaded via claude-flake"

      # Show available commands based on project type
      case "${projectType}" in
        rust)
          echo "💡 Try: cargo build, cargo test, cargo clippy"
          ;;
        python)
          echo "💡 Try: poetry install, poetry run, pytest"
          ;;
        nodejs)
          echo "💡 Try: npm install, yarn install, npm test"
          ;;
        go)
          echo "💡 Try: go build, go test, go mod tidy"
          ;;
        nix)
          echo "💡 Try: nix build, nix develop, nixfmt ."
          ;;
      esac
    '';

  # Validate project directory before generating .envrc
  validateProjectDirectory =
    projectPath:
    let
      isWritable = builtins.pathExists projectPath;
      hasGit = builtins.pathExists "${projectPath}/.git";
      hasEnvrc = builtins.pathExists "${projectPath}/.envrc";
    in
    {
      valid = isWritable;
      warnings =
        lib.optionals hasEnvrc [ "Existing .envrc will be overwritten" ]
        ++ lib.optionals (!hasGit) [ "Not a git repository - consider running 'git init'" ];
      errors = lib.optionals (!isWritable) [ "Directory not writable" ];
    };
}
