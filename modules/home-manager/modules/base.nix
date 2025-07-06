{
  config,
  lib,
  pkgs,
  ...
}:

let
  shellAliases = {
    ll = "eza -l";
    la = "eza -la";
    lt = "eza --tree";
    gs = "git status";
    gd = "git diff";
    gc = "git commit";
    gp = "git push";
    py = "python3";
    vim = "nvim";
    vi = "nvim";
    cat = "bat";
    # Development shell shortcuts
    devpy = "nix develop github:smithclay/claude-flake#pythonShell";
    devrust = "nix develop github:smithclay/claude-flake#rustShell";
  };
in
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
      ".tmux.conf".source = ../../../tmux.conf;
    };
  };

  programs = {
    git = {
      enable = true;
      userName = "Clay Smith";
      userEmail = "smithclay@gmail.com";
    };

    bash = {
      enable = true;
      inherit shellAliases;
    };

    zsh = {
      enable = true;
      inherit shellAliases;
    };

    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
  };
}
