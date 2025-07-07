{ mkDevShell, pkgs }:

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
  ''