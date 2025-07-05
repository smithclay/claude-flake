{
  description = "Dev shells: Rust and Python, both with Node + Claude setup and hook scripts";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nixpkgs, flake-utils, home-manager, ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};

      claudeSetup = ''
        echo "⚙️   Setting up Claude CLI and Task Master env"

        if ! command -v claude >/dev/null 2>&1; then
          echo "📦 Installing @anthropic-ai/claude-cli globally via npm..."
          npm install -g @anthropic-ai/claude-cli
        fi

        if ! command -v task-master >/dev/null 2>&1; then
          echo "📦 Installing task-master-ai globally via npm..."
          npm install -g task-master-ai
        fi

        if ! claude --version >/dev/null 2>&1; then
          echo "⚠️  Claude CLI not found after install"
        else
          echo "✅ Claude CLI ready: $(claude --version)"
        fi
        
        if ! task-master --version >/dev/null 2>&1; then
          echo "⚠️  Task Master not found after install"
        else
          echo "✅ Task Master ready: $(task-master --version)"
        fi
      '';

      mkDevShell = name: buildInputs: extraShellHook: pkgs.mkShell {
        name = name;
        buildInputs = buildInputs ++ [ pkgs.nodejs_22 ];
        shellHook = ''
          echo "🚀 Entered ${name} dev shell"
          ${claudeSetup}
          ${extraShellHook}
        '';
      };
    in
    {
      devShells = {
        "${system}" = {
          rustShell = mkDevShell "rust-shell" [
            pkgs.rustc
            pkgs.cargo
            pkgs.rustfmt
            pkgs.clippy
            pkgs.rust-analyzer
            pkgs.pkg-config
            pkgs.openssl
          ] ''
            echo "🦀 Rust toolchain ready"
            cargo --version
            rustc --version
          '';

          pythonShell = mkDevShell "python-shell" [
            pkgs.nodejs_22
	    pkgs.python3
            pkgs.python3Packages.pip
            pkgs.python3Packages.virtualenv
            pkgs.python3Packages.black
            pkgs.python3Packages.flake8
            pkgs.python3Packages.pytest
            pkgs.python3Packages.ipython
          ] ''
            echo "🐍 Python environment ready"
            python --version
          '';
        };
      };

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
                zsh
                tmux
                git
                curl
                wget
                jq
                tree
                htop
                neovim
              ];

              programs.zsh = {
                enable = true;
                oh-my-zsh = {
                  enable = true;
                  plugins = [ "git" "docker" "kubectl" "rust" "python" "npm" "sudo" "z" ];
                  theme = "robbyrussell";
                };
                shellAliases = {
                  ll = "ls -l";
                  la = "ls -la";
                  gs = "git status";
                  gd = "git diff";
                  gc = "git commit";
                  gp = "git push";
                  py = "python3";
                  vim = "nvim";
                  vi = "nvim";
                  # Dev shell shortcuts
                  devpy = "nix develop .#pythonShell";
                  devrust = "nix develop .#rustShell";
                };
                initExtra = ''
                  # Custom zsh config
                  export EDITOR="nvim"
                  export PATH="$HOME/.local/bin:$PATH"
                '';
              };

              home.sessionPath = [
                "$HOME/.npm-global/bin"
              ];

              home.sessionVariables = {
                NPM_CONFIG_PREFIX = "$HOME/.npm-global";
              };

              # Claude configuration
              home.file.".claude/settings.json".source = ./settings.json;
              home.file.".claude/CLAUDE.md".source = ./CLAUDE.md;
              home.file.".claude/hooks/smart-lint.sh" = {
                source = ./hooks/smart-lint.sh;
                executable = true;
              };
              home.file.".claude/hooks/ntfy-notifier.sh" = {
                source = ./hooks/ntfy-notifier.sh;
                executable = true;
              };
              
              # Tmux configuration
              home.file.".tmux.conf".source = ./tmux.conf;
              
              # Task master config
              home.file.".taskmaster/config.json".source = ./taskmaster-config.json;
            }
          ];
        };
      };
    };
}
