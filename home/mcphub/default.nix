{ pkgs, inputs, ... }:
{
  home.packages = [
    inputs.mcp-hub.packages."${system}".default
  ];

  xdg.configFile = {
    mcphub = {
      source = ./mcphub;
      force = true;
      recursive = true;
    };
  };
}
