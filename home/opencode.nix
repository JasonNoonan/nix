{ config, ... }:

{
  programs.opencode = {
    enable = true;
    settings = {
      "$schema" = "https://opencode.ai/config.json";
      theme = "opencode";
      model = "github-copilot/claude-sonnet-4";
      autoupdate = true;
      mcp = {
        mcphub = {
          type = "remote";
          url = "http://localhost:3000/mcp";
          enabled = true;
        };
        git = {
          type = "local";
          command = [
            "docker"
            "run"
            "--rm"
            "-i"
            "--mount"
            "type=bind,src=${config.home.homeDirectory},dst=${config.home.homeDirectory}"
            "mcp/git"
          ];
          enabled = true;
        };
      };
    };
  };
}
