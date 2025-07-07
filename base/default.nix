{
  config,
  lib,
  pkgs,
  ...
}:

{
  home = {
    packages = with pkgs; [
      # Shell and utilities
      yq
      ripgrep
      bat
      eza
      fzf
      tmux
      git
      gh
      curl
      wget
      jq
      tree
      htop
      neovim
    ];

    sessionPath = [
      "$HOME/.nix-profile/bin"
      "$HOME/.local/bin"
    ];

    file = {
      # Tmux configuration
      ".tmux.conf".source = ../tmux.conf;
    };
  };

  # Import shared shell configuration
  imports = [ ./shared-shell.nix ];

  programs = {
    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
  };
}
