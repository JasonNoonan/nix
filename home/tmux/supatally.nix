{ pkgs, ... }:
# Supacode analog of ./tally.nix: build the default pane/tab layout in the
# current Supacode worktree by driving the `supacode` CLI.
#
# Run manually from inside a Supacode terminal:  supatally
# Later this same body can be dropped into a Supacode worktree startup script.
#
# Note: the CLI has no rename command — tab titles auto-derive from whatever
# process is running in them (claude, nvim, lazygit, ...).
pkgs.writeShellScriptBin "supatally" ''
  set -euo pipefail

  # `supacode` on PATH can resolve to the GUI app binary, which blocks. Pin the
  # CLI shim explicitly and fall back to whatever is on PATH.
  SUPACODE="/Applications/supacode.app/Contents/Resources/bin/supacode"
  [ -x "$SUPACODE" ] || SUPACODE="$(command -v supacode || true)"

  if [ -z "$SUPACODE" ] || [ ! -x "$SUPACODE" ]; then
    echo "supatally: could not find the supacode CLI." >&2
    exit 1
  fi

  if [ -z "''${SUPACODE_SOCKET_PATH:-}" ] || [ -z "''${SUPACODE_WORKTREE_ID:-}" ]; then
    echo "supatally: must be run inside a Supacode terminal (SUPACODE_* env not set)." >&2
    exit 1
  fi

  # Standard tally layout, one tab per surface. Each -i command runs in a fresh
  # terminal with your normal interactive environment/PATH.
  AGENT_TAB=$("$SUPACODE" tab new -i "claude --dangerously-skip-permissions")
  "$SUPACODE" tab new -i "nvim"       >/dev/null   #  editor
  "$SUPACODE" tab new                 >/dev/null   #  plain terminal
  "$SUPACODE" tab new -i "nvim +DBUI" >/dev/null   #  database UI
  "$SUPACODE" tab new -i "lazygit"    >/dev/null   #  git

  # Leave focus on the agent tab (a new tab's surface id equals its tab id).
  "$SUPACODE" tab focus -t "$AGENT_TAB"
''
