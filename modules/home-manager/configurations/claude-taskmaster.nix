{
  config,
  lib,
  pkgs,
  ...
}:

{
  home = {
    username = "clay";
    homeDirectory = "/home/clay";
    stateVersion = "24.05";
  };

  # Import only Claude and Task Master functionality
  imports = [
    ../../../claude-tm/default.nix
  ];
}
