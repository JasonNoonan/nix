{ config, ... }:
{
  # Load the function-hook mods in ./mods in every session. Points at the repo's
  # working copy (not the store) so edits apply on the next session without a rebuild.
  home.sessionVariables.CLAUDE_CODE_PLUGIN_DIRS =
    "${config.home.homeDirectory}/.config/nix-darwin/home/claude/mods/linear-branch";

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
