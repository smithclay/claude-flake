{
  description = "Development shells for Rust and Python with AI tools";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        claudeSetup = ''
          echo "⚙️   Checking Claude CLI and Task Master env"

          if ! command -v claude >/dev/null 2>&1; then
            echo "⚠️  Claude CLI not found - please install with: npm install -g @anthropic-ai/claude-code"
          else
            echo "✅ Claude CLI ready: $(claude --version)"
          fi
          
          if ! command -v task-master >/dev/null 2>&1; then
            echo "⚠️  Task Master not found - please install with: npm install -g task-master-ai"
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
            pkgs.python3
            pkgs.python3Packages.pip
            pkgs.python3Packages.virtualenv
            pkgs.python3Packages.black
            pkgs.python3Packages.flake8
            pkgs.python3Packages.pytest
            pkgs.python3Packages.ipython
            pkgs.python3Packages.mypy
            pkgs.poetry
            pkgs.ruff
          ] ''
            echo "🐍 Python environment ready"
            python --version
          '';
        
          # Default to Python shell
          default = self.devShells.${system}.pythonShell;
        };
      }
    );
}