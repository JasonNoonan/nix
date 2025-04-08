{ pkgs, inputs, ... }:
{
  home.packages = [];

  xdg.configFile = {
    nvim = {
      source = ./nix;
      force = true;
      recursive = true;
    };
  };
}
