# lib/language-detection.nix - Intelligent project detection for opt-in enhancement
{ lib, ... }:

rec {
  # Detect project type based on file markers with priority rules
  detectProjectType =
    projectPath:
    let
      hasFile = file: builtins.pathExists "${projectPath}/${file}";

      # Priority order: User override → Nix → Go → Rust → Python → Node.js → Java → C/C++ → Shell → Fallback
      detectionRules = [
        {
          name = "nix";
          condition = hasFile "flake.nix" || hasFile "shell.nix" || hasFile "default.nix";
          priority = 1;
        }
        {
          name = "go";
          condition = hasFile "go.mod" || hasFile "go.sum";
          priority = 2;
        }
        {
          name = "rust";
          condition = hasFile "Cargo.toml" || hasFile "Cargo.lock";
          priority = 3;
        }
        {
          name = "python";
          condition = hasFile "pyproject.toml" || hasFile "requirements.txt" || hasFile "poetry.lock";
          priority = 4;
        }
        {
          name = "nodejs";
          condition = hasFile "package.json" || hasFile "yarn.lock" || hasFile "package-lock.json";
          priority = 5;
        }
        {
          name = "java";
          condition = hasFile "pom.xml" || hasFile "build.gradle" || hasFile "build.gradle.kts";
          priority = 6;
        }
        {
          name = "cpp";
          condition = hasFile "CMakeLists.txt" || hasFile "Makefile" || hasFile "meson.build";
          priority = 7;
        }
        {
          name = "shell";
          condition =
            hasFile "configure"
            || hasFile "autogen.sh"
            || (
              builtins.pathExists "${projectPath}"
              && (builtins.any (f: lib.hasSuffix ".sh" f || lib.hasSuffix ".bash" f) (
                builtins.attrNames (builtins.readDir projectPath)
              ))
            );
          priority = 8;
        }
      ];

      detected = lib.filter (rule: rule.condition) detectionRules;
      highest =
        if detected == [ ] then null else lib.head (lib.sort (a: b: a.priority < b.priority) detected);
    in
    if highest == null then "universal" else highest.name;

  # Check for user override in project directory
  checkUserOverride =
    projectPath:
    let
      overrideFile = "${projectPath}/.claude-env";
      envVar = builtins.getEnv "CLAUDE_ENV";
    in
    if builtins.pathExists overrideFile then
      lib.fileContents overrideFile
    else if envVar != "" then
      envVar
    else
      null;

  # Get final project type with override support
  getProjectType =
    projectPath:
    let
      override = checkUserOverride projectPath;
      detected = detectProjectType projectPath;
    in
    if override != null then override else detected;

  # Get human-readable description of detected project
  getProjectDescription =
    projectType:
    let
      descriptions = {
        nix = "Nix development environment";
        go = "Go module project";
        rust = "Rust package with Cargo";
        python = "Python project with dependencies";
        nodejs = "Node.js project with npm/yarn";
        java = "Java project with Maven/Gradle";
        cpp = "C/C++ project with build system";
        shell = "Shell scripting project";
        universal = "Universal development environment";
      };
    in
      descriptions.${projectType} or "Unknown project type";

  # List all detected project markers for debugging
  listDetectedMarkers =
    projectPath:
    let
      hasFile = file: builtins.pathExists "${projectPath}/${file}";
      allMarkers = [
        {
          file = "flake.nix";
          present = hasFile "flake.nix";
          language = "nix";
        }
        {
          file = "shell.nix";
          present = hasFile "shell.nix";
          language = "nix";
        }
        {
          file = "go.mod";
          present = hasFile "go.mod";
          language = "go";
        }
        {
          file = "Cargo.toml";
          present = hasFile "Cargo.toml";
          language = "rust";
        }
        {
          file = "pyproject.toml";
          present = hasFile "pyproject.toml";
          language = "python";
        }
        {
          file = "requirements.txt";
          present = hasFile "requirements.txt";
          language = "python";
        }
        {
          file = "package.json";
          present = hasFile "package.json";
          language = "nodejs";
        }
        {
          file = "pom.xml";
          present = hasFile "pom.xml";
          language = "java";
        }
        {
          file = "build.gradle";
          present = hasFile "build.gradle";
          language = "java";
        }
        {
          file = "CMakeLists.txt";
          present = hasFile "CMakeLists.txt";
          language = "cpp";
        }
        {
          file = "Makefile";
          present = hasFile "Makefile";
          language = "cpp";
        }
        {
          file = "configure";
          present = hasFile "configure";
          language = "shell";
        }
      ];
    in
    lib.filter (marker: marker.present) allMarkers;
}
