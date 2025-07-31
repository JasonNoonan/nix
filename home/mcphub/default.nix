{ ... }:
{
  xdg.configFile = {
    mcphub = {
      source = ./mcphub;
      force = true;
      recursive = true;
    };
  };
}
