{
  description = "Claude Code configuration and dev shells";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      home-manager,
    }:
    let
      devShellsModule = import ./modules/dev-shells/default.nix;
      homeManagerModule = import ./modules/home-manager/flake.nix;
    in
    {
      # Import dev shells from modules
      inherit
        (devShellsModule {
          inherit self nixpkgs flake-utils;
        })
        devShells
        ;

      # Import home configurations from modules
      inherit
        (homeManagerModule.outputs {
          inherit self nixpkgs home-manager;
        })
        homeConfigurations
        ;
    };
}
