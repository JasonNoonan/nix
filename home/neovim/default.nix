{ pkgs, inputs, ... }:
{
  home.packages = [
    pkgs.cargo
    pkgs.nixpkgs-fmt
    pkgs.nodePackages.nodejs
    pkgs.postgresql_14
    pkgs.gnumake
  ];

  programs.lazygit.enable = true;

  programs.neovim = {
    enable = true;
    defaultEditor = true;
  };

  xdg.configFile = {
    nvim = {
      source = inputs.astronvim;
      force = true;
      recursive = true;
    };

    "astronvim/lua/user" = {
      source = ./neovim;
      force = true;
      recursive = true;
    };
  };
}
