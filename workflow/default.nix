# workflow/default.nix - Main opinionated workflow
{ pkgs, lib, ... }:

{
  # Import all workflow components
  imports = [
    ./claude-config.nix
    ./shell-integration.nix
  ];

  # User configuration (will be set at runtime)
  home = {
    username = lib.mkDefault (builtins.getEnv "USER");
    homeDirectory = lib.mkDefault (
      if (builtins.getEnv "USER") != "" then
        if pkgs.stdenv.isDarwin then
          "/Users/${builtins.getEnv "USER"}"
        else
          "/home/${builtins.getEnv "USER"}"
      else
        "/home/user"
    );
    stateVersion = "23.11";
  };

  # Enable home-manager
  programs.home-manager.enable = true;

  # Custom activation script with post-install message
  home.activation.showPostInstallMessage = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        $DRY_RUN_CMD cat << 'EOF'

    🎉 Claude-Flake installed!

    Add to your .bashrc or .zshrc:
      source ~/.config/claude-flake/loader.sh

    Then run: claude or cf

    EOF
  '';
}
