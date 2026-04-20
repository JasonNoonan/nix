{ ... }:
{
  home.file.".config/sidecar/config.json" = {
    source = ./config.json;
    force = true;
  };
}
