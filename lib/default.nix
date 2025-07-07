# lib/default.nix - Shared utilities for claude-flake intelligent project detection
{ lib, pkgs, ... }:

{
  # Export language detection functions
  languageDetection = import ./language-detection.nix { inherit lib; };

  # Export language package sets
  languagePackages = import ./language-packages.nix { inherit pkgs; };

  # Export envrc template generation
  envrcTemplates = import ./envrc-templates.nix { inherit lib; };

  # Utility function to get complete project configuration
  getProjectConfig =
    projectPath: flakeUrl:
    let
      detection = import ./language-detection.nix { inherit lib; };
      packages = import ./language-packages.nix { inherit pkgs; };
      templates = import ./envrc-templates.nix { inherit lib; };

      projectType = detection.getProjectType projectPath;
      projectPackages = packages.getPackagesForType projectType;
      envrcContent = templates.generateCompleteEnvrc projectType flakeUrl;
      validation = templates.validateProjectDirectory projectPath;
    in
    {
      inherit
        projectType
        projectPackages
        envrcContent
        validation
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
