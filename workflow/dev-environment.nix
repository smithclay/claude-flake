# workflow/dev-environment.nix - Universal development environment
{ pkgs, ... }:

{
  # Home configuration (consolidated to avoid repeated keys)
  home = {
    packages = with pkgs; [
      # Core development tools
      git
      gh
      gitui

      # Modern CLI tools
      bat
      eza
      fzf
      ripgrep
      yq
      jq
      tree

      nodejs_22 # Required for Claude CLI
    ];

    # PATH configuration
    sessionPath = [
      "$HOME/.nix-profile/bin"
    ];

  };
}
