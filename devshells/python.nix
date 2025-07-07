{ mkDevShell, pkgs }:

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
  ''
