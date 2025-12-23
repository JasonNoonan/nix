{ pkgs, inputs, ... }:
{
  home.packages = [
    inputs.opencode.packages.${pkgs.system}.default
  ];

  xdg.configFile = {
    opencode = {
      source = ./opencode;
      force = true;
      recursive = true;
    };
  };
}
