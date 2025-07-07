{ config, pkgs, ... }:

{
  # Claude-Flake single loader - eliminates clobbering entirely
  # Creates one file with all shell configuration
  
  home = {
    file = {
      ".config/claude-flake/loader.sh".text = ''
        #!/bin/bash
        # Claude-Flake Shell Configuration Loader
        # Managed by home-manager - do not edit manually
        # For user customizations, create ~/.config/claude-flake/local.sh
        
        # =============================================================================
        # FLAKE DEVELOPMENT ALIASES
        # =============================================================================
        
        # Home-manager shortcuts for our flake
        if command -v home-manager >/dev/null 2>&1; then
          alias hm='nix run home-manager --'
          alias hms='nix run home-manager -- switch --flake $CLAUDE_FLAKE#claude-taskmaster'
        fi
        
        # Development shell shortcuts for our flake
        if command -v nix >/dev/null 2>&1; then
          alias devpy='nix develop github:smithclay/claude-flake#pythonShell'
          alias devrust='nix develop github:smithclay/claude-flake#rustShell'
        fi
        
        # Task-master shortcuts
        if command -v task-master >/dev/null 2>&1; then
          alias tm='task-master'
        fi
        
        # =============================================================================
        # USER CUSTOMIZATIONS
        # =============================================================================
        
        # Load user customizations if they exist
        [[ -r ~/.config/claude-flake/local.sh ]] && source ~/.config/claude-flake/local.sh
        
        # Mark as loaded
        export CLAUDE_FLAKE_LOADED="1"
      '';

      # Create local customization file (user-editable)
      ".config/claude-flake/local.sh".text = ''
        # Claude-Flake Local Customizations
        # This file is safe to edit manually - your changes won't be overwritten
        
        # Add your personal aliases, functions, and environment variables here
        # 
        # Common examples:
        # alias ll='ls -la'           # File listing
        # alias vim='nvim'            # Editor preference
        # alias gs='git status'       # Git shortcuts
        # export EDITOR="code"        # Editor preference
        # 
        # Development shortcuts:
        # alias dc='docker-compose'
        # alias k='kubectl'
        # alias tf='terraform'
        # 
        # To override claude-flake aliases:
        # unalias tm
        # alias tm='my-task-manager'
      '';
    };

    # Environment variables
    sessionVariables = {
      CLAUDE_FLAKE_LOADED = "1";
    };
  };
}
