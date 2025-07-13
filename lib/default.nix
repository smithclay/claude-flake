# lib/default.nix - Shared utilities for claude-flake intelligent project detection
{ lib, pkgs, ... }:

{
  # Export language detection functions
  languageDetection = import ./language-detection.nix { inherit lib; };

  # Export language package sets
  languagePackages = import ./language-packages.nix { inherit pkgs; };

  # Utility function to get complete project configuration
  getProjectConfig =
    projectPath:
    let
      detection = import ./language-detection.nix { inherit lib; };
      packages = import ./language-packages.nix { inherit pkgs; };

      projectType = detection.getProjectType projectPath;
      projectPackages = packages.getPackagesForType projectType;
    in
    {
      inherit
        projectType
        projectPackages
        ;
      description = detection.getProjectDescription projectType;
      markers = detection.listDetectedMarkers projectPath;
      shellHook = packages.getShellHook projectType;
    };

  # Helper function to create devShells for flake.nix
  createDevShells =
    pkgs:
    let
      packages = import ./language-packages.nix { inherit pkgs; };
      supportedTypes = [
        "rust"
        "python"
        "nodejs"
        "go"
        "nix"
        "universal"
      ];

      makeDevShell =
        projectType:
        let
          shellPackages = packages.getPackagesForType projectType;
          shellHook = packages.getShellHook projectType;
        in
        pkgs.mkShell {
          buildInputs = shellPackages;
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
