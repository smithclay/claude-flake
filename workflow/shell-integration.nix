# workflow/shell-integration.nix - Minimal shell integration for claude-flake
_:

{
  # Loader script with essential functionality
  home.file = {
    # Version file with dynamic content from VERSION file
    ".config/claude-flake/VERSION".text = builtins.readFile ../VERSION;

    # Minimal loader script
    ".config/claude-flake/loader.sh".text = ''
      #!/usr/bin/env bash
      # Claude-Flake loader system - Essential shell integration

      # Claude-Flake environment marker
      export CLAUDE_FLAKE_LOADED=1

      # NPM global directory setup  
      export NPM_CONFIG_PREFIX="$HOME/.npm-global"

      # Add Node.js and npm global bins to PATH (from claude-config.nix installation)
      if [ -d "$HOME/.nvm/versions/node" ]; then
        # Use nvm node if available
        export PATH="$HOME/.nvm/versions/node/$(ls $HOME/.nvm/versions/node | tail -1)/bin:$PATH"
      fi
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
      if [ -f "$HOME/.config/claude-flake/VERSION" ]; then
        version=$(cat "$HOME/.config/claude-flake/VERSION" 2>/dev/null | tr -d '\n\r' || echo "2.0.0")
        echo "claude-flake v$version loaded"
      else
        echo "claude-flake loaded"
      fi
    '';

    # Copy cf script to config directory
    ".config/claude-flake/scripts/cf" = {
      source = ../scripts/cf;
      executable = true;
    };
  };
}
