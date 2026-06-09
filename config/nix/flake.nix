{
  description = "My Home Manager config";

  # These act as the dependancies for the flake
  inputs = {
    # This is getting the url so we can access nix packages
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # This is setting up home-manager so we can do some configuration (it installs home-manager)
    home-manager = {
      url = "github:nix-community/home-manager";
      # this is so we only have on version of nixpkgs instead of the specified one above and the home-manager version
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  # what the flake produces as output
  outputs = { nixpkgs, home-manager, ... }:
    let
      system = "x86_64-linux";
      # this sets where we are grabbing packages from
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      # here is where we specify that this is the saven profile
      homeConfigurations.saven =
        home-manager.lib.homeManagerConfiguration {
          inherit pkgs;

          modules = [
            ./home.nix
          ];
        };
    };
}
