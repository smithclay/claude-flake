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
    { self
    , nixpkgs
    , home-manager
    , ...
    }:
    let
      # Support multiple systems
      systems = [
        "x86_64-linux"
        "aarch64-linux"
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
          extraSpecialArgs = {
            inherit
              self
              nixpkgs
              username
              homeDirectory
              ;
          };
        };
    in
    {
      # Home Manager configurations - dynamic with --impure
      homeConfigurations =
        let
          # Pull in $USER from environment (requires --impure)
          username = builtins.getEnv "USER";

          # Compute home directory based on system
          homeDir = if username != "" then "/home/${username}" else "/home/user";

          # Use the detected user or fallback
          finalUsername = if username != "" then username else "user";
        in
        {
          # Single dynamic configuration based on current user
          "${finalUsername}" = mkHomeConfiguration "x86_64-linux" finalUsername homeDir;
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

      # Function to create home configuration for any user (can be imported by other flakes)
      lib.mkHomeConfigurationForUser =
        { username
        , system ? "x86_64-linux"
        , homeDirectory ? "/home/${username}"
        ,
        }:
        mkHomeConfiguration system username homeDirectory;

      # Apps for easy activation
      apps = forAllSystems (
        system:
        let
          # Get username from environment (requires --impure)
          username = builtins.getEnv "USER";
          finalUsername = if username != "" then username else "user";
        in
        {
          # Define a run-target called "home" that points at the activationPackage
          home = {
            type = "app";
            program = "${self.homeConfigurations.${finalUsername}.activationPackage}/activate";
            meta = {
              description = "Activate the home-manager configuration for Claude Code workflow";
              longDescription = ''
                This app activates the home-manager configuration that sets up
                the complete Claude Code development environment with all necessary
                tools, configurations, and workflows.
              '';
              homepage = "https://github.com/your-org/claude-flake";
              license = nixpkgs.lib.licenses.mit;
              maintainers = [ "Claude Code Team" ];
              platforms = nixpkgs.lib.platforms.linux;
            };
          };
        }
      );
    };
}
