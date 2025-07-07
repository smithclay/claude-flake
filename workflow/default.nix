# workflow/default.nix - Main opinionated workflow
{ pkgs, lib, ... }:

{
  # Import all workflow components
  imports = [
    ./dev-environment.nix
    ./claude-config.nix
    ./shell-integration.nix
  ];

  # User configuration (will be set at runtime)
  home = {
    username = lib.mkDefault "user";
    homeDirectory = lib.mkDefault "/home/user";
    stateVersion = "23.11";
  };

  # Enable home-manager
  programs.home-manager.enable = true;
}
