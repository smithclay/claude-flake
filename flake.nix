{
  description = "Modular Nix configuration with dev shells and home-manager";

  inputs = {
    dev-shells.url = "path:./dev-shells";
    home-manager-config.url = "path:./home-manager";
  };

  outputs =
    {
      self,
      dev-shells,
      home-manager-config,
    }:
    {
      # Re-export dev shells for convenience
      inherit (dev-shells) devShells;

      # Re-export home configurations
      inherit (home-manager-config) homeConfigurations;
    };
}
