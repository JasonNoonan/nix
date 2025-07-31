{ ... }:
{
  home.file.".claude/agents" = {
      source = ./agents;
      force = true;
      recursive = true;
    };
}
