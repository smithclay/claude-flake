{
  description = "Modular Nix configuration with dev shells and home-manager";

  inputs = {
    dev-shells.url = "path:./dev-shells";
    home-manager-config.url = "path:./home-manager";
  };

  outputs = { self, dev-shells, home-manager-config }:
    {
      # Re-export dev shells for convenience
      devShells = dev-shells.devShells;
      
      # Re-export home configurations
      homeConfigurations = home-manager-config.homeConfigurations;
    };
}