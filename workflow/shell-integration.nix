# workflow/shell-integration.nix - Claude-Flake automatic shell integration
_:

{
  # Phase 3A: Automatic shell integration with home-manager
  # Direct configuration of bash and zsh through home-manager programs

  # Automatic bash configuration
  programs.bash = {
    enable = false;
    enableCompletion = true;

    # Claude-Flake aliases
    shellAliases = {
      # Home-manager shortcuts
      hm = "home-manager";
      hms = "home-manager switch";

      # Task Master shortcuts
      tm = "task-master";

      # Claude-Flake management
      claude-flake-update = "nix flake update && home-manager switch --flake github:smithclay/claude-flake";
      claude-flake-local = "home-manager switch --flake path:$HOME/.config/claude-flake";

      # Development utilities (modern CLI tools)
      grep = "rg";

      # Git shortcuts
      gs = "git status";
      ga = "git add";
      gc = "git commit";
      gp = "git push";
      gl = "git log --oneline";

      # Claude-Flake project enhancement
      claude-flake-init-project = "${../scripts/init-project.sh}";
      cf-init = "${../scripts/init-project.sh}";
      cf-help = "echo 'Claude-Flake Commands:' && echo '  cf-init [DIR]    - Initialize project with .envrc' && echo '  cf-help          - Show this help' && echo '  tm               - Task Master' && echo '  hm               - Home Manager'";
    };

    # Custom initialization for bash
    initExtra = ''
      # Claude-Flake environment marker
      export CLAUDE_FLAKE_LOADED=1

      # Function to check if command exists
      command_exists() {
        command -v "$1" >/dev/null 2>&1
      }

      # Conditional loading based on available commands
      if command_exists claude; then
        echo "✅ Claude CLI available"
      fi

      if command_exists task-master; then
        echo "✅ Task Master available"
      fi

      # Source user customizations if they exist
      if [ -f "$HOME/.config/claude-flake/local.sh" ]; then
        source "$HOME/.config/claude-flake/local.sh"
      fi
    '';
  };

  # Automatic zsh configuration
  programs.zsh = {
    enable = false;
    enableCompletion = true;

    # Same aliases as bash for consistency
    shellAliases = {
      # Home-manager shortcuts
      hm = "home-manager";
      hms = "home-manager switch";

      # Task Master shortcuts
      tm = "task-master";

      # Claude-Flake management
      claude-flake-update = "nix flake update && home-manager switch --flake github:smithclay/claude-flake";
      claude-flake-local = "home-manager switch --flake path:$HOME/.config/claude-flake";

      # Development utilities (modern CLI tools)
      grep = "rg";

      # Git shortcuts
      gs = "git status";
      ga = "git add";
      gc = "git commit";
      gp = "git push";
      gl = "git log --oneline";

      # Claude-Flake project enhancement
      claude-flake-init-project = "${../scripts/init-project.sh}";
      cf-init = "${../scripts/init-project.sh}";
      cf-help = "echo 'Claude-Flake Commands:' && echo '  cf-init [DIR]    - Initialize project with .envrc' && echo '  cf-help          - Show this help' && echo '  tm               - Task Master' && echo '  hm               - Home Manager'";
    };

    # Custom initialization for zsh
    initContent = ''
      # Claude-Flake environment marker
      export CLAUDE_FLAKE_LOADED=1

      # Function to check if command exists
      command_exists() {
        command -v "$1" >/dev/null 2>&1
      }

      # Conditional loading based on available commands
      if command_exists claude; then
        echo "✅ Claude CLI available"
      fi

      if command_exists task-master; then
        echo "✅ Task Master available"
      fi

      # Source user customizations if they exist
      if [ -f "$HOME/.config/claude-flake/local.sh" ]; then
        source "$HOME/.config/claude-flake/local.sh"
      fi
    '';
  };

  # Environment variables for detection
  home.sessionVariables = {
    CLAUDE_FLAKE_LOADED = "1";
  };

  # Preserve loader system for backward compatibility during transition
  home.file = {
    # Loader script with all aliases and functions
    ".config/claude-flake/loader.sh".text = ''
      #!/usr/bin/env bash
      # Claude-Flake loader system - Manual shell integration
      # Source this file in your .bashrc or .zshrc to get claude-flake aliases

      # Claude-Flake environment marker
      export CLAUDE_FLAKE_LOADED=1

      # NPM global directory setup
      export NPM_CONFIG_PREFIX="$HOME/.npm-global"
      export PATH="$HOME/.npm-global/bin:$PATH"

      # Home-manager shortcuts
      alias hm="home-manager"
      alias hms="home-manager switch"

      # Task Master shortcuts
      alias tm="task-master"

      # Claude-Flake management
      alias claude-flake-update="nix flake update && home-manager switch --flake github:smithclay/claude-flake"
      alias claude-flake-local="home-manager switch --flake path:$HOME/.config/claude-flake"

      # Development utilities (modern CLI tools)
      alias grep="rg"

      # Git shortcuts
      alias gs="git status"
      alias ga="git add"
      alias gc="git commit"
      alias gp="git push"
      alias gl="git log --oneline"

      # Claude-Flake project enhancement
      alias claude-flake-init-project="${../scripts/init-project.sh}"
      alias cf-init="${../scripts/init-project.sh}"
      alias cf-help='echo "Claude-Flake Commands:" && echo "  cf-init [DIR]    - Initialize project with .envrc" && echo "  cf-help          - Show this help" && echo "  tm               - Task Master" && echo "  hm               - Home Manager"'

      # Function to check if command exists
      command_exists() {
        command -v "$1" >/dev/null 2>&1
      }

      # Direnv integration
      if command_exists direnv; then
        eval "$(direnv hook bash)"
        eval "$(direnv hook zsh)"
        echo "✅ Direnv hooks enabled"
      fi

      # Conditional loading based on available commands
      if command_exists claude; then
        echo "✅ Claude CLI available"
      fi

      if command_exists task-master; then
        echo "✅ Task Master available"
      fi

      # Source user customizations if they exist
      if [ -f "$HOME/.config/claude-flake/local.sh" ]; then
        source "$HOME/.config/claude-flake/local.sh"
      fi
    '';

    # User customization file (preserved for user configurations)
    ".config/claude-flake/local.sh".text = ''
      #!/usr/bin/env bash
      # Claude-Flake local customizations
      # Add your custom aliases, functions, and configurations here
      # This file is sourced by the automatic shell integration

      # Example customizations:
      # alias myproject="cd ~/projects/myproject && claude"
      # export MY_CUSTOM_VAR="value"

      # Your customizations below:

    '';
  };
}
