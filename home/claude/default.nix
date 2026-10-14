{ ... }:
{
  home.file.".claude/agents" = {
      source = ./agents;
      force = true;
      recursive = true;
    };

  # recursive = true links each skill file individually, so non-nix skills
  # (e.g. supacode-cli, installed by other tools) can coexist under ~/.claude/skills.
  home.file.".claude/skills" = {
      source = ./skills;
      force = true;
      recursive = true;
    };

  home.file.".config/claude/.mcp.json" = {
      source = ./config/.mcp.json;
      force = true;
    };
}
