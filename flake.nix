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
    # Experimental features for performance (safe for all users)
    experimental-features = [
      "nix-command"
      "flakes"
    ];

    # Build settings for better performance (safe for all users)
    keep-going = true;
    fallback = true;
    max-jobs = "auto";
    cores = 0; # Use all available cores
    connect-timeout = 5;
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
        "aarch64-darwin"
      ];
      forAllSystems = nixpkgs.lib.genAttrs systems;

      # Helper function to determine home directory based on system
      getHomeDirectory =
        system: username:
        if nixpkgs.lib.hasSuffix "darwin" system then "/Users/${username}" else "/home/${username}";

      # Function to create home configuration for any system/user
      mkHomeConfiguration =
        system: username: homeDirectory:
        assert builtins.isString system;
        assert builtins.isString username;
        assert builtins.isString homeDirectory;
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
      homeConfigurations = forAllSystems (
        system:
        let
          # Pull in $USER from environment (requires --impure)
          username = builtins.getEnv "USER";

          # Use the detected user or fallback
          finalUsername = if username != "" then username else "user";

          # Compute home directory based on system
          homeDir =
            if username != "" then getHomeDirectory system username else getHomeDirectory system "user";
        in
        {
          # Single dynamic configuration based on current user
          "${finalUsername}" = mkHomeConfiguration system finalUsername homeDir;
        }
      );

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
        {
          username,
          system ? "x86_64-linux",
          homeDirectory ? null,
        }:
        let
          finalHomeDirectory =
            if homeDirectory != null then homeDirectory else getHomeDirectory system username;
        in
        mkHomeConfiguration system username finalHomeDirectory;

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
            program = "${self.homeConfigurations.${system}.${finalUsername}.activationPackage}/activate";
            meta = {
              description = "Activate claude-flake home configuration for current user";
              maintainers = [ "claude-flake" ];
            };
          };
        }
      );
    };
}
