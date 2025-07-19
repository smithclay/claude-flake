# workflow/claude-config.nix - Claude Code environment setup
{ pkgs, lib, ... }:

{
  # NPM global configuration and Claude CLI setup
  home = {
    # Essential packages for Claude Code workflow
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

      # Nix tooling
      nixfmt-rfc-style # Official Nix formatter
      nixfmt-tree # Zero-setup treefmt with nixfmt
      nix-tree # Dependency visualization

      nodejs_22 # Required for Claude CLI
    ];

    # PATH management
    sessionPath = [
      "$HOME/.nix-profile/bin"
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
      ".claude/commands/commit.md".source = ../files/commands/commit.md;
    };

    # Automatic installation of Claude CLI
    activation.installClaudeTools = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      # Set up proper PATH including npm global directory
      export NPM_CONFIG_PREFIX="$HOME/.npm-global"
      export PATH="${pkgs.nodejs_22}/bin:$HOME/.npm-global/bin:$PATH"

      # Create npm global directory if it doesn't exist
      mkdir -p "$HOME/.npm-global/bin"

      # Install Claude CLI if not present
      if ! command -v claude >/dev/null 2>&1; then
        echo "Installing Claude CLI..."
        npm install -g @anthropic-ai/claude-code
      fi

      # Verify installations with updated PATH
      if command -v claude >/dev/null 2>&1; then
        echo "✅ Claude CLI installed: $(claude --version 2>/dev/null || echo 'version check failed')"
      else
        echo "❌ Claude CLI installation failed - PATH: $PATH"
        echo "   Debug: npm global bin directory contents:"
        ls -la "$HOME/.npm-global/bin/" 2>/dev/null || echo "   No .npm-global/bin directory found"
      fi

    '';
  };
}
