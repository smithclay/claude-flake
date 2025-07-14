# lib/default.nix - Shared utilities for claude-flake development shells
{ lib, pkgs, ... }:

let
  # Import language packages once for better performance
  languagePackages = import ./language-packages.nix { inherit pkgs; };
in
{
  # Export language package sets
  inherit languagePackages;

  # Helper function to create devShells for flake.nix
  # Returns an attribute set of development shells for different project types
  createDevShells =
    pkgs:
    let
      packages = languagePackages;
      supportedTypes = [
        "rust"
        "python"
        "nodejs"
        "go"
        "nix"
        "java"
        "cpp"
        "shell"
        "universal"
      ];

      makeDevShell =
        projectType:
        let
          shellPackages = packages.getPackagesForType projectType;
          shellHook = packages.getShellHook projectType;
        in
        pkgs.mkShell {
          buildInputs = shellPackages ++ [
            # Add cf script to all shells
            (pkgs.writeShellScriptBin "cf" (builtins.readFile ../scripts/cf))
          ];
          CLAUDE_FLAKE_SHELL_TYPE = projectType;
          shellHook = ''
            ${shellHook}

            # Project-specific setup
            if [ -f .claude-env ]; then
              echo "Loading project overrides from .claude-env"
              source .claude-env
            fi
          '';
        };
    in
    lib.genAttrs supportedTypes makeDevShell;
}
