{
  description = "Example Darwin system flake";

  nixConfig = {
    experimental-features = [ "nix-command" "flakes" ];

    substituters = [
      "https://cache.nixos.org"
    ];

    extraSubstituters = [
      "https://nix-community.cachix.org"
    ];

    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    # lexical-lsp.url = "github:lexical-lsp/lexical/aa11bd6";
  };

  outputs = inputs@{ self, home-manager, nix-darwin, nixpkgs, ... }:
    {
      darwinConfigurations = {
        "cyan" = nix-darwin.lib.darwinSystem {
          modules =
            [
              ./hosts/cyan
              home-manager.darwinModules.home-manager
              {
                home-manager.useGlobalPkgs = true;
                home-manager.useUserPackages = true;
                home-manager.users.jasonnoonan = import ./home/cyan;
                home-manager.extraSpecialArgs = { inherit inputs; };
              }
            ];
          specialArgs = { inherit inputs self; };
        };

        "locke" = nix-darwin.lib.darwinSystem {
          modules =
            [
              ./hosts/locke
              home-manager.darwinModules.home-manager
              {
                home-manager.useGlobalPkgs = true;
                home-manager.useUserPackages = true;
                home-manager.users.jasonnoonan = import ./home/locke;
                home-manager.extraSpecialArgs = { inherit inputs; };
              }
            ];
          specialArgs = { inherit inputs self; };
        };
      };

      # Expose the package set, including overlays, for convenience.
      darwinPackages = self.darwinConfigurations."Jasons-MacBook-Pro-2".pkgs;
    };
}
