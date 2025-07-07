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
    NixOS-WSL = {
      url = "github:nix-community/NixOS-WSL";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    # lexical-lsp.url = "github:lexical-lsp/lexical/aa11bd6";
    mcp-hub.url = "github:ravitemer/mcp-hub";
  };

  outputs = inputs@{ self, home-manager, nix-darwin, nixpkgs, NixOS-WSL, ... }:
    {
      nixpkgs.config.allowBroken = true;
      nixpkgs.config.allowUnfree = true;
      nixpkgs.config.permittedInsecurePackages = [
                "dotnet-sdk-6.0.428"
              ];

      darwinConfigurations = {
        "cyan" = nix-darwin.lib.darwinSystem {
          modules =
            [
              ./hosts/cyan
              home-manager.darwinModules.home-manager
              {
                home-manager.useGlobalPkgs = true;
                home-manager.useUserPackages = true;
                home-manager.users.jasonnoonan = { ... }: {
                  home.username = "jasonnoonan";
                  home.homeDirectory = "/Users/jasonnoonan";

                  imports = [
                    ./home/cyan
                  ];
                };
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

      nixosConfigurations = {
        shadow = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs; };

          modules = [
            ./hosts/shadow
            NixOS-WSL.nixosModules.wsl
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = { inherit inputs; };
              home-manager.users.jasonnoonan = { ... }: {
                home.username = "jasonnoonan";
                home.homeDirectory = "/home/jasonnoonan";

                imports = [
                  ./home/shadow
                ];
              };
            }
          ];
        };

        terra = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs; };

          modules = [
            ./hosts/terra
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = { inherit inputs; };
              home-manager.users.jasonnoonan = import ./home/terra;
            }
          ];
        };

        iso = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-graphical-plasma5-new-kernel.nix"
            ({ pkgs, ... }: {
              environment.systemPackages = with pkgs; [ neovim git networkmanager ];

              systemd.services.sshd.wantedBy = pkgs.lib.mkForce [ "multi-user.target" ];
              users.users.root.openssh.authorizedKeys.keys = [
                "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINd2/EJEh7VrpMXZwcpF4Hel1OxNbv/qfqt5JbmEe+8k jason.t.noonan@gmail.com"
              ];
            })
          ];
        };
      };
    };
}
