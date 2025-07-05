{
  description = "Home Manager configuration for Clay";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      homeConfigurations = {
        clay = home-manager.lib.homeManagerConfiguration {
          pkgs = pkgs;
    
          modules = [
            {
              home.username = "clay";
              home.homeDirectory = "/home/clay";
              home.stateVersion = "24.05";
              
              home.packages = with pkgs; [
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

              programs.git = {
                enable = true;
                userName = "Clay Smith";
                userEmail = "smithclay@gmail.com";
              };

              programs.zsh = {
                enable = true;
                oh-my-zsh = {
                  enable = true;
                  plugins = [ "git" "docker" "rust" "python" "npm" "sudo" "z" ];
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
                  devpy = "nix develop ../dev-shells#pythonShell";
                  devrust = "nix develop ../dev-shells#rustShell";
                  dev = "nix develop ../dev-shells"; # Uses default shell
                };
              };

              programs.direnv = {
                enable = true;
                nix-direnv.enable = true;
              };

              home.sessionPath = [
                "$HOME/.nix-profile/bin"
                "$HOME/.npm-global/bin"
                "$HOME/.local/share/npm/bin"
                "$HOME/.local/bin"
              ];

              home.sessionVariables = {
                NPM_CONFIG_PREFIX = "$HOME/.npm-global";
              };

              home.activation = {
                installGlobalNpmPackages = home-manager.lib.hm.dag.entryAfter ["writeBoundary"] ''
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

              # Claude configuration
              home.file.".claude/settings.json".source = ../settings.json;
              home.file.".claude/CLAUDE.md".source = ../CLAUDE.md;
              home.file.".claude/hooks/smart-lint.sh" = {
                source = ../hooks/smart-lint.sh;
                executable = true;
              };
              home.file.".claude/hooks/ntfy-notifier.sh" = {
                source = ../hooks/ntfy-notifier.sh;
                executable = true;
              };
              
              # Tmux configuration
              home.file.".tmux.conf".source = ../tmux.conf;
            }
          ];
        };
      };
    };
}