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
      homeConfigurations =
        let
          # Function to create configurations for any username
          mkUserConfigs = username: {
            "${username}@linux" = mkHomeConfiguration "x86_64-linux" username "/home/${username}";
            "${username}@darwin" = mkHomeConfiguration "x86_64-darwin" username "/Users/${username}";
            "${username}@aarch64-linux" = mkHomeConfiguration "aarch64-linux" username "/home/${username}";
            "${username}@aarch64-darwin" = mkHomeConfiguration "aarch64-darwin" username "/Users/${username}";
          };
        in
        # Create configurations for common usernames
        (mkUserConfigs "user")
        // (mkUserConfigs "claude")
        // (mkUserConfigs "dev")
        // (mkUserConfigs "developer");

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

      # Note: Apps section removed - use direct home-manager commands instead:
      # nix run nixpkgs#home-manager -- switch --flake .#claude@linux --accept-flake-config
    };
}
