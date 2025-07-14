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
      claude-flake-update = "nix flake update";
      claude-flake-switch = "home-manager switch --flake \"$(__claude_flake_source)\"";

      # Git shortcuts
      gs = "git status";
      ga = "git add";
      gc = "git commit";
      gp = "git push";
      gl = "git log --oneline";
      gd = "git diff";
      gdc = "git diff --cached";
      gb = "git branch";
      gco = "git checkout";
      gcb = "git checkout -b";
      gf = "git fetch";
      gpl = "git pull";
      gm = "git merge";
      gr = "git rebase";
      gst = "git stash";
      gsp = "git stash pop";
      gss = "git stash show";
      gcp = "git cherry-pick";
      glo = "git log --oneline --graph --decorate";
      gla = "git log --oneline --graph --decorate --all";

      # Common system aliases
      ".." = "cd ..";
      "..." = "cd ../..";
      "...." = "cd ../../..";
      ll = "ls -la";
      la = "ls -la";
      l = "ls -l";
      cls = "clear";
      c = "clear";
      h = "history";
      j = "jobs";
      v = "vim";
      e = "echo";
      p = "pwd";
      md = "mkdir -p";
      rd = "rmdir";
      cp = "cp -i";
      mv = "mv -i";
      rm = "rm -i";
      df = "df -h";
      du = "du -h";
      free = "free -h";
      ps = "ps aux";
      top = "htop";
      wget = "wget -c";
      curl = "curl -L";
      tree = "tree -C";
      find = "find . -name";
      mount = "mount | column -t";
      path = "echo -e $PATH | tr \":\" \"\\n\"";
      now = "date +'%Y-%m-%d %H:%M:%S'";
      today = "date +'%Y-%m-%d'";
      myip = "curl -s http://whatismyip.akamai.com/";
      localip = "hostname -I | cut -d' ' -f1";
      ports = "netstat -tuln";
      untar = "tar -zxvf";
      grep = "grep --color=auto";
      egrep = "egrep --color=auto";
      fgrep = "fgrep --color=auto";
      make = "make -j$(nproc)";

      # Claude-Flake shortcuts
      cf-rust = "nix develop \"$(__claude_flake_source)#rust\"";
      cf-python = "nix develop \"$(__claude_flake_source)#python\"";
      cf-nodejs = "nix develop \"$(__claude_flake_source)#nodejs\"";
      cf-go = "nix develop \"$(__claude_flake_source)#go\"";
      cf-nix = "nix develop \"$(__claude_flake_source)#nix\"";
      cf-help = "echo 'Claude-Flake Commands:' && echo '  cf-rust          - Rust development shell' && echo '  cf-python        - Python development shell' && echo '  cf-nodejs        - Node.js development shell' && echo '  cf-go            - Go development shell' && echo '  cf-nix           - Nix development shell' && echo '  cf-help          - Show this help' && echo '  tm               - Task Master' && echo '  hm               - Home Manager' && echo '' && echo 'Override flake source with: export CLAUDE_FLAKE_SOURCE=path:/path/to/local/claude-flake'";
    };

    # Custom initialization for bash
    initExtra = ''
      # Claude-Flake environment marker
      export CLAUDE_FLAKE_LOADED=1

      # Function to check if command exists
      command_exists() {
        command -v "$1" >/dev/null 2>&1
      }

      # Function to get flake source (GitHub by default, local via CLAUDE_FLAKE_SOURCE)
      __claude_flake_source() {
        echo "''${CLAUDE_FLAKE_SOURCE:-github:smithclay/claude-flake}"
      }

      # Claude-Flake prompt function for nix shells
      __claude_flake_prompt() {
        if [ -n "$IN_NIX_SHELL" ]; then
          local indicator=""
          case "$CLAUDE_FLAKE_SHELL_TYPE" in
            rust) indicator="🦀 " ;;
            python) indicator="🐍 " ;;
            nodejs) indicator="🟢 " ;;
            go) indicator="🐹 " ;;
            nix) indicator="❄️  " ;;
            *) indicator="🔧 " ;;
          esac
          echo "$indicator"
        fi
      }

      # Set up PS1 with Claude-Flake indicator
      if [[ "$PS1" != *"__claude_flake_prompt"* ]]; then
        export PS1='$(__claude_flake_prompt)'"$PS1"
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
      claude-flake-update = "nix flake update";
      claude-flake-switch = "home-manager switch --flake \"$(__claude_flake_source)\"";

      # Git shortcuts
      gs = "git status";
      ga = "git add";
      gc = "git commit";
      gp = "git push";
      gl = "git log --oneline";

      # Claude-Flake shortcuts
      cf-rust = "nix develop \"$(__claude_flake_source)#rust\"";
      cf-python = "nix develop \"$(__claude_flake_source)#python\"";
      cf-nodejs = "nix develop \"$(__claude_flake_source)#nodejs\"";
      cf-go = "nix develop \"$(__claude_flake_source)#go\"";
      cf-nix = "nix develop \"$(__claude_flake_source)#nix\"";
      cf-help = "echo 'Claude-Flake Commands:' && echo '  cf-rust          - Rust development shell' && echo '  cf-python        - Python development shell' && echo '  cf-nodejs        - Node.js development shell' && echo '  cf-go            - Go development shell' && echo '  cf-nix           - Nix development shell' && echo '  cf-help          - Show this help' && echo '  tm               - Task Master' && echo '  hm               - Home Manager' && echo '' && echo 'Override flake source with: export CLAUDE_FLAKE_SOURCE=path:/path/to/local/claude-flake'";
    };

    # Custom initialization for zsh
    initContent = ''
      # Claude-Flake environment marker
      export CLAUDE_FLAKE_LOADED=1

      # Function to check if command exists
      command_exists() {
        command -v "$1" >/dev/null 2>&1
      }

      # Function to get flake source (GitHub by default, local via CLAUDE_FLAKE_SOURCE)
      __claude_flake_source() {
        echo "''${CLAUDE_FLAKE_SOURCE:-github:smithclay/claude-flake}"
      }

      # Claude-Flake prompt function for nix shells
      __claude_flake_prompt() {
        if [ -n "$IN_NIX_SHELL" ]; then
          local indicator=""
          case "$CLAUDE_FLAKE_SHELL_TYPE" in
            rust) indicator="🦀 " ;;
            python) indicator="🐍 " ;;
            nodejs) indicator="🟢 " ;;
            go) indicator="🐹 " ;;
            nix) indicator="❄️  " ;;
            *) indicator="🔧 " ;;
          esac
          echo "$indicator"
        fi
      }

      # Set up PROMPT with Claude-Flake indicator
      setopt PROMPT_SUBST
      if [[ "$PROMPT" != *"__claude_flake_prompt"* ]]; then
        export PROMPT='$(__claude_flake_prompt)'"$PROMPT"
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

      # Function to get flake source (GitHub by default, local via CLAUDE_FLAKE_SOURCE)
      __claude_flake_source() {
        echo "''${CLAUDE_FLAKE_SOURCE:-github:smithclay/claude-flake}"
      }

      # Claude-Flake prompt function for nix shells
      __claude_flake_prompt() {
        if [ -n "$IN_NIX_SHELL" ]; then
          local indicator=""
          case "$CLAUDE_FLAKE_SHELL_TYPE" in
            rust) indicator="🦀 " ;;
            python) indicator="🐍 " ;;
            nodejs) indicator="🟢 " ;;
            go) indicator="🐹 " ;;
            nix) indicator="❄️  " ;;
            *) indicator="🔧 " ;;
          esac
          echo "$indicator"
        fi
      }

      # Set up prompt based on shell type
      if [ -n "$BASH_VERSION" ]; then
        # Bash prompt setup
        if [[ "$PS1" != *"__claude_flake_prompt"* ]]; then
          export PS1='$(__claude_flake_prompt)'"$PS1"
        fi
      elif [ -n "$ZSH_VERSION" ]; then
        # Zsh prompt setup
        setopt PROMPT_SUBST 2>/dev/null || true
        if [[ "$PROMPT" != *"__claude_flake_prompt"* ]]; then
          export PROMPT='$(__claude_flake_prompt)'"$PROMPT"
        fi
      fi

      # Home-manager shortcuts
      alias hm="home-manager"
      alias hms="home-manager switch"

      # Task Master shortcuts
      alias tm="task-master"

      # Claude-Flake management
      alias claude-flake-update="nix flake update"
      alias claude-flake-switch="home-manager switch --flake \"$(__claude_flake_source)\""

      # Git shortcuts
      alias gs="git status"
      alias ga="git add"
      alias gc="git commit"
      alias gp="git push"
      alias gl="git log --oneline"
      alias gd="git diff"
      alias gdc="git diff --cached"
      alias gb="git branch"
      alias gco="git checkout"
      alias gcb="git checkout -b"
      alias gf="git fetch"
      alias gpl="git pull"
      alias gm="git merge"
      alias gr="git rebase"
      alias gst="git stash"
      alias gsp="git stash pop"
      alias gss="git stash show"
      alias gcp="git cherry-pick"
      alias glo="git log --oneline --graph --decorate"
      alias gla="git log --oneline --graph --decorate --all"

      # Common system aliases
      alias ..="cd .."
      alias ...="cd ../.."
      alias ....="cd ../../.."
      alias ll="ls -la"
      alias la="ls -la"
      alias l="ls -l"
      alias cls="clear"
      alias c="clear"
      alias h="history"
      alias j="jobs"
      alias v="vim"
      alias e="echo"
      alias p="pwd"
      alias md="mkdir -p"
      alias rd="rmdir"
      alias cp="cp -i"
      alias mv="mv -i"
      alias rm="rm -i"
      alias df="df -h"
      alias du="du -h"
      alias free="free -h"
      alias ps="ps aux"
      alias top="htop"
      alias wget="wget -c"
      alias curl="curl -L"
      alias tree="tree -C"
      alias find="find . -name"
      alias mount="mount | column -t"
      alias path='echo -e $PATH | tr ":" "\n"'
      alias now="date +'%Y-%m-%d %H:%M:%S'"
      alias today="date +'%Y-%m-%d'"
      alias myip="curl -s http://whatismyip.akamai.com/"
      alias localip="hostname -I | cut -d' ' -f1"
      alias ports="netstat -tuln"
      alias untar="tar -zxvf"
      alias grep="grep --color=auto"
      alias egrep="egrep --color=auto"
      alias fgrep="fgrep --color=auto"
      alias make="make -j$(nproc)"

      # Claude-Flake shortcuts
      alias cf-rust="nix develop \"$(__claude_flake_source)#rust\""
      alias cf-python="nix develop \"$(__claude_flake_source)#python\""
      alias cf-nodejs="nix develop \"$(__claude_flake_source)#nodejs\""
      alias cf-go="nix develop \"$(__claude_flake_source)#go\""
      alias cf-nix="nix develop \"$(__claude_flake_source)#nix\""
      alias cf-help='echo "Claude-Flake Commands:" && echo "  cf-rust          - Rust development shell" && echo "  cf-python        - Python development shell" && echo "  cf-nodejs        - Node.js development shell" && echo "  cf-go            - Go development shell" && echo "  cf-nix           - Nix development shell" && echo "  cf-help          - Show this help" && echo "  tm               - Task Master" && echo "  hm               - Home Manager" && echo "" && echo "Override flake source with: export CLAUDE_FLAKE_SOURCE=path:/path/to/local/claude-flake"'

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
