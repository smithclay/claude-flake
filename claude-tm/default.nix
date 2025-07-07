{
  config,
  lib,
  pkgs,
  ...
}:

{
  home = {
    packages = with pkgs; [
      nodejs_22 # Required for Claude CLI and Task Master
    ];

    sessionPath = [
      "$HOME/.npm-global/bin"
      "$HOME/.local/share/npm/bin"
    ];

    sessionVariables = {
      NPM_CONFIG_PREFIX = "$HOME/.npm-global";
      CLAUDE_FLAKE = "$HOME/workspace/claude-flake";
    };

    activation = {
      installGlobalNpmPackages = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        PATH="${pkgs.nodejs_22}/bin:$PATH"
        export NPM_CONFIG_PREFIX="$HOME/.npm-global"

        if ! command -v claude >/dev/null 2>&1; then
          echo "Installing @anthropic-ai/claude-code..."
          npm install -g @anthropic-ai/claude-code
        fi

        if ! command -v task-master >/dev/null 2>&1; then
          echo "Installing task-master-ai..."
          npm install -g task-master-ai
        fi
      '';
    };

    file = {
      # Claude configuration
      ".claude/settings.json".source = ../settings.json;
      ".claude/CLAUDE.md".source = ../CLAUDE.md;
      ".claude/hooks/smart-lint.sh" = {
        source = ../hooks/smart-lint.sh;
        executable = true;
      };
      ".claude/hooks/ntfy-notifier.sh" = {
        source = ../hooks/ntfy-notifier.sh;
        executable = true;
      };

      # Claude commands
      ".claude/commands/check.md".source = ../commands/check.md;
      ".claude/commands/next.md".source = ../commands/next.md;
      ".claude/commands/prompt.md".source = ../commands/prompt.md;
    };
  };

  # Import shared shell configuration
  imports = [ ../base/shared-shell.nix ];
}