{
  description = "Example Darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    astronvim = {
      url = "github:AstroNvim/AstroNvim/v3.40.3";
      flake = false;
    };
    lexical-lsp.url = "github:lexical-lsp/lexical";
  };

  outputs = inputs@{ self, home-manager, nix-darwin, nixpkgs, ... }:
    {
      darwinConfigurations."Jasons-MacBook-Pro-2" = nix-darwin.lib.darwinSystem {
        modules =
          [
            ./configuration.nix
            home-manager.darwinModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.jasonnoonan = import ./home/home.nix;
              home-manager.extraSpecialArgs = { inherit inputs; };
            }
          ];
        specialArgs = { inherit inputs self; };
      };

      # Expose the package set, including overlays, for convenience.
      darwinPackages = self.darwinConfigurations."Jasons-MacBook-Pro-2".pkgs;
    };
}
