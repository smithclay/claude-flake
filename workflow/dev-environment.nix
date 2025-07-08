# workflow/dev-environment.nix - Universal development environment
{ pkgs, ... }:

{
  # Home configuration (consolidated to avoid repeated keys)
  home = {
    # Essential development packages
    packages = with pkgs; [
      # Core development tools
      git
      gh
      neovim
      tmux

      # Modern CLI tools
      bat
      eza
      fzf
      ripgrep
      yq
      curl
      wget
      jq
      tree
      htop

      # Language runtimes (minimal essential)
      nodejs_22 # Required for Claude CLI
      python3 # Most common development language

      # Development utilities
      direnv
      nix-direnv
      nixfmt-rfc-style
      statix
    ];

    # PATH configuration
    sessionPath = [
      "$HOME/.nix-profile/bin"
      "$HOME/.local/bin"
    ];

    # Tmux configuration
    file.".tmux.conf".source = ../files/tmux.conf;
  };

  # Direnv integration
  programs.direnv = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };
}
