{ pkgs, inputs, ... }:
{
  xdg.configFile = {
    opencode = {
      source = ./opencode;
      force = true;
      recursive = true;
    };
  };
}
