# Module that exports dev shells for the main flake
{
  self,
  nixpkgs,
  flake-utils,
}:
flake-utils.lib.eachDefaultSystem (
  system:
  let
    pkgs = nixpkgs.legacyPackages.${system};

    claudeSetup = import ../common/claude-setup.nix { inherit pkgs; };

    mkDevShell =
      name: buildInputs: extraShellHook:
      pkgs.mkShell {
        inherit name;
        buildInputs = buildInputs ++ [
          pkgs.nodejs_22
          pkgs.nixfmt-rfc-style
          pkgs.statix
        ];
        shellHook = ''
          echo "🚀 Entered ${name} dev shell"
          ${claudeSetup}
          ${extraShellHook}
        '';
      };
  in
  {
    devShells = {
      rustShell =
        mkDevShell "rust-shell"
          [
            pkgs.rustc
            pkgs.cargo
            pkgs.rustfmt
            pkgs.clippy
            pkgs.rust-analyzer
            pkgs.pkg-config
            pkgs.openssl
          ]
          ''
            echo "🦀 Rust toolchain ready"
            cargo --version
            rustc --version
          '';

      pythonShell =
        mkDevShell "python-shell"
          [
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
          ]
          ''
            echo "🐍 Python environment ready"
            python --version
          '';

      # Default to Python shell
      default =
        mkDevShell "python-shell"
          [
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
          ]
          ''
            echo "🐍 Python environment ready"
            python --version
          '';
    };
  }
)
