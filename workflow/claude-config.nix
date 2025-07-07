# workflow/claude-config.nix - Claude + Task Master setup
{ pkgs, lib, ... }:

{
  # NPM global configuration and Claude CLI setup
  home = {
    # PATH management for NPM global packages
    sessionPath = [
      "$HOME/.npm-global/bin"
    ];

    # Environment variables
    sessionVariables = {
      NPM_CONFIG_PREFIX = "$HOME/.npm-global";
      CLAUDE_FLAKE = "$HOME/workspace";
    };

    # Claude configuration deployment
    file = {
      # Claude settings
      ".claude/settings.json".source = ../files/claude/settings.json;

      # Claude context file
      ".claude/CLAUDE.md".source = ../files/claude/CLAUDE.md;

      # Hook scripts with executable permissions
      ".claude/hooks/smart-lint.sh" = {
        source = ../files/hooks/smart-lint.sh;
        executable = true;
      };

      ".claude/hooks/ntfy-notifier.sh" = {
        source = ../files/hooks/ntfy-notifier.sh;
        executable = true;
      };

      # Custom slash commands
      ".claude/commands/check.md".source = ../files/commands/check.md;
      ".claude/commands/next.md".source = ../files/commands/next.md;
      ".claude/commands/prompt.md".source = ../files/commands/prompt.md;
    };

    # Automatic installation of Claude CLI and Task Master
    activation.installClaudeTools = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      PATH="${pkgs.nodejs_22}/bin:$PATH"
      export NPM_CONFIG_PREFIX="$HOME/.npm-global"

      # Create npm global directory if it doesn't exist
      mkdir -p "$HOME/.npm-global"

      # Install Claude CLI if not present
      if ! command -v claude >/dev/null 2>&1; then
        echo "Installing Claude CLI..."
        npm install -g @anthropic-ai/claude-code
      fi

      # Install Task Master if not present
      if ! command -v task-master >/dev/null 2>&1; then
        echo "Installing Task Master..."
        npm install -g task-master-ai
      fi

      # Configure MCP server
      if command -v claude >/dev/null 2>&1; then
        echo "✅ Claude CLI installed: $(claude --version 2>/dev/null || echo 'version check failed')"
      else
        echo "❌ Claude CLI installation failed"
      fi

      if command -v task-master >/dev/null 2>&1; then
        echo "✅ Task Master installed: $(task-master --version 2>/dev/null || echo 'version check failed')"
      else
        echo "❌ Task Master installation failed"
      fi
    '';
  };
}
