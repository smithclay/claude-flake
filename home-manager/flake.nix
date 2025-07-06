{
  description = "Home Manager configuration for Clay";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
    }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      homeConfigurations = {
        clay = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;

          modules = [
            {
              home = {
                username = "clay";
                homeDirectory = "/home/clay";
                stateVersion = "24.05";

                packages = with pkgs; [
                  # Shell and utilities
                  yq
                  ripgrep
                  fd
                  bat
                  eza
                  fzf
                  zsh
                  tmux
                  git
                  gh
                  curl
                  wget
                  jq
                  tree
                  htop
                  neovim
                  nodejs_22
                ];

                sessionPath = [
                  "$HOME/.nix-profile/bin"
                  "$HOME/.npm-global/bin"
                  "$HOME/.local/share/npm/bin"
                  "$HOME/.local/bin"
                ];

                sessionVariables = {
                  NPM_CONFIG_PREFIX = "$HOME/.npm-global";
                  GENAI_NIX_FLAKE = "$HOME/workspace/genai-nix-flake";
                };

                activation = {
                  installGlobalNpmPackages = home-manager.lib.hm.dag.entryAfter [ "writeBoundary" ] ''
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

                  # Tmux configuration
                  ".tmux.conf".source = ../tmux.conf;
                };
              };

              programs = {
                git = {
                  enable = true;
                  userName = "Clay Smith";
                  userEmail = "smithclay@gmail.com";
                };

                zsh = {
                  enable = true;
                  oh-my-zsh = {
                    enable = true;
                    plugins = [
                      "git"
                      "docker"
                      "rust"
                      "python"
                      "npm"
                      "sudo"
                      "z"
                    ];
                    theme = "robbyrussell";
                  };
                  shellAliases = {
                    ll = "eza -l";
                    la = "eza -la";
                    lt = "eza --tree";
                    gs = "git status";
                    gd = "git diff";
                    gc = "git commit";
                    gp = "git push";
                    py = "python3";
                    vim = "nvim";
                    vi = "nvim";
                    cat = "bat";
                    find = "fd";
                    # Dev shell shortcuts
                    devpy = "nix develop $GENAI_NIX_FLAKE/dev-shells#pythonShell";
                    devrust = "nix develop $GENAI_NIX_FLAKE/dev-shells#rustShell";
                    dev = "nix develop $GENAI_NIX_FLAKE/dev-shells"; # Uses default shell
                    # Home-manager shortcuts
                    hm = "nix run home-manager --";
                    hms = "nix run home-manager -- switch --flake $GENAI_NIX_FLAKE/home-manager#clay";
                  };
                };

                direnv = {
                  enable = true;
                  nix-direnv.enable = true;
                };
              };
            }
          ];
        };
      };
    };
}
