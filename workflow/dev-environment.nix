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
      python3
    ];

    # PATH configuration
    sessionPath = [
      "$HOME/.nix-profile/bin"
      "$HOME/.local/bin"
    ];

  };
}
