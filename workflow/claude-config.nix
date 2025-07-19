# workflow/claude-config.nix - Claude Code environment setup
{
  pkgs,
  lib,
  claude-code-nix,
  ...
}:

{
  # Claude Code environment setup with Nix
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

      # Claude CLI via Nix
      claude-code-nix.packages.${pkgs.system}.default
    ];

    # PATH management
    sessionPath = [
      "$HOME/.nix-profile/bin"
      "$HOME/.local/bin"
    ];

    # Environment variables
    sessionVariables = {
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

    # Verify Claude CLI installation
    activation.verifyClaudeTools = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      # Verify Claude CLI is available
      if command -v claude >/dev/null 2>&1; then
        echo "✅ Claude CLI installed: $(claude --version 2>/dev/null || echo 'version check failed')"
      else
        echo "❌ Claude CLI not found in PATH: $PATH"
        echo "   Available in nix store: ${claude-code-nix.packages.${pkgs.system}.default}/bin/claude"
      fi
    '';
  };
}
