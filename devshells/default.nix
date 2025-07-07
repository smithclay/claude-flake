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

    claudeSetup = import ../claude-tm/setup.nix { inherit pkgs; };

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
      rustShell = import ./rust.nix { inherit mkDevShell pkgs; };
      pythonShell = import ./python.nix { inherit mkDevShell pkgs; };
      # Default to Python shell
      default = import ./python.nix { inherit mkDevShell pkgs; };
    };
  }
)
