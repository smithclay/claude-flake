# workflow/shell-integration.nix - Minimal shell integration for claude-flake
_:

{
  # Loader script with essential functionality
  home.file = {
    # Minimal loader script
    ".config/claude-flake/loader.sh".text = ''
      #!/usr/bin/env bash
      # Claude-Flake loader system - Essential shell integration

      # Claude-Flake environment marker
      export CLAUDE_FLAKE_LOADED=1

      # NPM global directory setup  
      export NPM_CONFIG_PREFIX="$HOME/.npm-global"
      export PATH="$HOME/.npm-global/bin:$PATH"

      # Add claude-flake scripts to PATH
      if [ -d "$HOME/.config/claude-flake/scripts" ]; then
        export PATH="$HOME/.config/claude-flake/scripts:$PATH"
      fi

      # Function to check if command exists
      command_exists() {
        command -v "$1" >/dev/null 2>&1
      }

      # Show claude-flake version and loaded status
      echo "claude-flake v2.0.0 loaded"
    '';

    # Copy cf script to config directory
    ".config/claude-flake/scripts/cf" = {
      source = ../scripts/cf;
      executable = true;
    };
  };
}
