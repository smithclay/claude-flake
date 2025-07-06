{
  description = "Home Manager configuration for Clay";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
    }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      homeConfigurations = {
        # Base development environment (no Claude dependencies)
        base = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [ ./configurations/base.nix ];
        };

        # Claude + Task Master only (no development tools)
        claude-taskmaster = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [ ./configurations/claude-taskmaster.nix ];
        };
      };
    };
}
