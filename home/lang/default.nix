{ pkgs, inputs, ... }:
{
  home.packages = [];

  xdg.configFile = {
    nix = {
      source = ./nix;
      force = true;
      recursive = true;
    };
  };
}
