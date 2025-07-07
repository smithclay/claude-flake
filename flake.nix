{
  description = "Opinionated Claude Code workflow orchestrated with Nix";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  nixConfig = {
    # Optimized binary cache configuration for performance
    substituters = [
      "https://cache.nixos.org/"
      "https://nix-community.cachix.org"
    ];
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];

    # Build optimization settings
    builders-use-substitutes = true;
    max-jobs = "auto";
    cores = 0; # Use all available cores

    # Network and download optimizations
    connect-timeout = 5;
    download-attempts = 3;

    # Experimental features for performance
    experimental-features = [
      "nix-command"
      "flakes"
    ];

    # Build settings for better performance
    keep-going = true;
    fallback = true;
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      ...
    }:
    let
      # Support multiple systems
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
      forAllSystems = nixpkgs.lib.genAttrs systems;

      # Function to create home configuration for any system/user
      mkHomeConfiguration =
        system: username: homeDirectory:
        home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.${system};
          modules = [
            ./workflow/default.nix
            {
              home = {
                inherit username homeDirectory;
              };
            }
          ];
          extraSpecialArgs = { inherit self nixpkgs; };
        };
    in
    {
      # Home Manager configurations for common setups
      homeConfigurations = {
        # Generic configuration (user should override username/homeDirectory)
        "user@linux" = mkHomeConfiguration "x86_64-linux" "user" "/home/user";
        "user@darwin" = mkHomeConfiguration "x86_64-darwin" "user" "/Users/user";
        "user@aarch64-linux" = mkHomeConfiguration "aarch64-linux" "user" "/home/user";
        "user@aarch64-darwin" = mkHomeConfiguration "aarch64-darwin" "user" "/Users/user";
      };

      # DevShells for project-specific environments
      devShells = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          inherit (nixpkgs) lib;
          claudeFlakeLib = import ./lib { inherit lib pkgs; };
          shells = claudeFlakeLib.createDevShells pkgs;
        in
        shells
        // {
          # Default devShell points to universal for maximum compatibility
          default = shells.universal;
        }
      );

      # Apps for quick setup
      apps = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          homeDir = if pkgs.stdenv.isDarwin then "/Users" else "/home";
        in
        {
          default = {
            type = "app";
            program = "${pkgs.writeScript "claude-flake-setup" ''
              #!/usr/bin/env bash

              USERNAME="''${USER:-$(whoami)}"
              SYSTEM="${system}"

              echo "🚀 Setting up Claude Code workflow for $USERNAME on $SYSTEM"

              # Determine configuration based on system
              case "$SYSTEM" in
                x86_64-linux) CONFIG="user@linux" ;;
                aarch64-linux) CONFIG="user@aarch64-linux" ;;
                x86_64-darwin) CONFIG="user@darwin" ;;
                aarch64-darwin) CONFIG="user@aarch64-darwin" ;;
                *) CONFIG="user@linux" ;;
              esac

              echo "📦 Using configuration: $CONFIG"
              echo "🏠 Home directory: ${homeDir}/$USERNAME"

              # Install home-manager if not available
              if ! command -v home-manager >/dev/null 2>&1; then
                echo "📦 Installing home-manager..."
                nix profile install nixpkgs#home-manager || {
                  echo "❌ Failed to install home-manager"
                  echo "💡 You can install manually with: nix profile install nixpkgs#home-manager"
                  exit 1
                }
                echo "✅ home-manager installed successfully"
              fi

              # Determine flake URL based on context
              if [ -n "''${NIX_FLAKE_URL:-}" ]; then
                FLAKE_URL="$NIX_FLAKE_URL"
              elif [ -f "${self}/flake.nix" ]; then
                FLAKE_URL="${self}"
              else
                FLAKE_URL="github:smithclay/claude-flake"
              fi

              echo "⚡ Executing: home-manager switch --flake $FLAKE_URL#$CONFIG"
              echo "🏠 This will set up Claude Code workflow for $USERNAME"
              echo ""

              # Execute the home-manager switch command
              if home-manager switch --flake "$FLAKE_URL#$CONFIG"; then
                echo ""
                echo "🎉 Claude Code workflow setup complete!"
                echo "✅ Claude CLI and Task Master will be available after shell reload"
                echo "💡 Run 'source ~/.bashrc' or start a new shell session"
                echo ""
                echo "🚀 Quick start:"
                echo "  claude        # Start Claude Code"
                echo "  task-master   # Task Master CLI" 
                echo "  tm           # Task Master shortcut"
              else
                echo ""
                echo "❌ Setup failed!"
                echo "💡 Manual installation:"
                echo "    home-manager switch --flake $FLAKE_URL#$CONFIG"
                exit 1
              fi
            ''}";
            meta = {
              description = "Opinionated Claude Code workflow orchestrated with Nix";
              platforms = nixpkgs.lib.platforms.all;
            };
          };
        }
      );
    };
}
