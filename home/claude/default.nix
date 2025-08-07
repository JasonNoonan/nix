{ ... }:
{
  home.file.".claude/agents" = {
      source = ./agents;
      force = true;
      recursive = true;
    };

  home.file.".config/claude/.mcp.json" = {
      source = ./config/.mcp.json;
      force = true;
    };
}
