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

  # Import only base development tools
  imports = [
    ../../../base/default.nix
  ];
}
