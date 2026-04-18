{ pkgs, ... }:
{
  home.packages = [
    pkgs.opencode
  ];

  xdg.configFile = {
    opencode = {
      source = ./opencode;
      force = true;
      recursive = true;
    };
  };
}
