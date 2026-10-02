{ config, pkgs, ... }:
# herdr (https://herdr.dev) agent multiplexer, set up to mirror the Supacode
# workflow in ../supacode and ../tmux/supatally.nix:
#
#   - hwt (https://hwt.doriankarter.com) creates configured worktrees and runs
#     the old Supacode setup script (mise trust/install, mix setup, tally layout)
#   - hally / herdr-tally-layout are the herdr analogs of
#     supacode-tally / supatally
#   - vellum (https://vellum.doriankarter.com) provides the command palette
#
# herdr, hwt, and vellum are installed by mise (nixpkgs lags herdr releases and
# hwt/vellum are only published as GitHub releases). After a rebuild run
# `mise install`, then the one-time per-machine steps in ./README.md.
let
  # Inside Herdr panes, popups, and plugin hooks HERDR_BIN_PATH points at the
  # running server's binary; outside them fall back to PATH (mise shims).
  herdrFn = ''
    herdr() {
      if [[ -n "''${HERDR_BIN_PATH:-}" ]]; then
        "$HERDR_BIN_PATH" "$@"
      else
        command herdr "$@"
      fi
    }
  '';

  herdrTallyLayout = pkgs.writeShellApplication {
    name = "herdr-tally-layout";
    runtimeInputs = [ pkgs.coreutils pkgs.jq ];
    text = ''
      WORKSPACE_ID=""
      TARGET_CWD=""
      FORCE=0
      AGENT_COMMAND="''${HERDR_TALLY_AGENT:-claude --dangerously-skip-permissions}"

      while [[ $# -gt 0 ]]; do
        case "$1" in
          -w|--workspace)
            [[ $# -ge 2 ]] || { echo "missing value for $1" >&2; exit 2; }
            WORKSPACE_ID="$2"
            shift 2
            ;;
          --cwd)
            [[ $# -ge 2 ]] || { echo "missing value for $1" >&2; exit 2; }
            TARGET_CWD="$2"
            shift 2
            ;;
          --agent)
            [[ $# -ge 2 ]] || { echo "missing value for $1" >&2; exit 2; }
            AGENT_COMMAND="$2"
            shift 2
            ;;
          --force)
            FORCE=1
            shift
            ;;
          -h|--help)
            cat <<'USAGE'
      Usage: herdr-tally-layout [--workspace ID | --cwd PATH] [--force] [--agent CMD]

      Seeds a Herdr workspace with the tally layout (herdr analog of supatally):
      agent, nvim, term, web (terminal-browser), db (nvim +DBUI), git (lazygit),
      and dash (gh dash) tabs.

      The workspace defaults to $HERDR_WORKSPACE_ID (inside a Herdr pane), else
      the workspace whose pane cwd matches --cwd / $PWD (e.g. hwt post_create).
      Workspaces that already have more than one tab are left alone unless --force.
      USAGE
            exit 0
            ;;
          *)
            echo "unknown option: $1" >&2
            exit 2
            ;;
        esac
      done

      ${herdrFn}

      if [[ -z "$WORKSPACE_ID" && -z "$TARGET_CWD" && -n "''${HERDR_WORKSPACE_ID:-}" ]]; then
        WORKSPACE_ID="$HERDR_WORKSPACE_ID"
      fi

      if [[ -z "$WORKSPACE_ID" ]]; then
        TARGET_CWD="''${TARGET_CWD:-$PWD}"
        physical_cwd="$(cd "$TARGET_CWD" && pwd -P)"
        WORKSPACE_ID="$(
          herdr pane list \
            | jq -r --arg a "$TARGET_CWD" --arg b "$physical_cwd" \
                '[.result.panes[] | select(.cwd == $a or .cwd == $b)][0].workspace_id // empty'
        )"
      fi

      if [[ -z "$WORKSPACE_ID" ]]; then
        echo "herdr-tally-layout: no Herdr workspace found for ''${TARGET_CWD:-current pane}." >&2
        echo "Run it inside a Herdr pane or pass --workspace." >&2
        exit 1
      fi

      tabs="$(herdr tab list --workspace "$WORKSPACE_ID")"
      tab_count="$(jq '.result.tabs | length' <<<"$tabs")"
      if [[ "$tab_count" -gt 1 && "$FORCE" != "1" ]]; then
        echo "Workspace $WORKSPACE_ID already has $tab_count tabs; leaving the layout intact (use --force to append)." >&2
        exit 0
      fi

      root_tab="$(jq -r '.result.tabs | min_by(.number) | .tab_id' <<<"$tabs")"
      root_pane="$(
        herdr pane list --workspace "$WORKSPACE_ID" \
          | jq -r --arg t "$root_tab" '[.result.panes[] | select(.tab_id == $t)][0]'
      )"
      root_pane_id="$(jq -r .pane_id <<<"$root_pane")"
      root_cwd="$(jq -r .cwd <<<"$root_pane")"

      new_tab() {
        local label="$1" command="$2" created pane
        created="$(herdr tab create --workspace "$WORKSPACE_ID" --cwd "$root_cwd" --label "$label" --no-focus)"
        pane="$(jq -r .result.root_pane.pane_id <<<"$created")"
        if [[ -n "$command" ]]; then
          herdr pane run "$pane" "$command" >/dev/null
        fi
      }

      new_tab nvim "nvim"
      new_tab term ""
      new_tab web "terminal-browser"
      new_tab db "nvim +DBUI"
      new_tab git "lazygit"
      new_tab dash "gh dash"

      # The root tab keeps focus; start the agent there last so it is typed into
      # the shell even when this script was launched from that same pane.
      if [[ "$tab_count" -le 1 ]]; then
        herdr tab rename "$root_tab" agent >/dev/null
        herdr pane run "$root_pane_id" "$AGENT_COMMAND" >/dev/null
      fi

      echo "Seeded tally layout in Herdr workspace $WORKSPACE_ID"
    '';
  };

  herdrTallyInputs = [
    pkgs.coreutils
    pkgs.eza
    pkgs.findutils
    pkgs.fzf
    pkgs.git
    pkgs.jq
    herdrTallyLayout
  ];

  herdrTally = pkgs.writeShellApplication {
    name = "hally";
    runtimeInputs = herdrTallyInputs;
    text = ''
      # PATH as the caller had it, without the runtimeInputs prefix, so a server
      # started from here doesn't leak these store paths into every pane.
      CALLER_PATH="''${PATH#${pkgs.lib.makeBinPath herdrTallyInputs}:}"
      TARGET="''${1:-}"

      if [[ "$TARGET" == "-h" || "$TARGET" == "--help" ]]; then
        cat <<'USAGE'
      Usage: hally [PROJECT_DIR]

      Pick a project like tally, open (or focus) it as a Herdr workspace, and seed
      the tally layout. Bound to prefix+shift+o.

      Outside Herdr (e.g. a fresh Ghostty shell) it starts the server if needed
      and attaches to it afterwards.
      USAGE
        exit 0
      fi

      ${herdrFn}

      # Not running inside a Herdr pane/popup: we'll need to attach at the end.
      ATTACH=0
      [[ -z "''${HERDR_BIN_PATH:-}" ]] && ATTACH=1

      server_running() {
        [[ "$(herdr status server 2>/dev/null)" == *"status: running"* ]]
      }

      # Start the server detached from this shell (e.g. after a reboot), so it
      # outlives the terminal that launched it.
      if ! server_running; then
        (cd "$HOME" && PATH="$CALLER_PATH" exec nohup herdr server) </dev/null >/dev/null 2>&1 &
        for _ in $(seq 50); do
          server_running && break
          sleep 0.1
        done
        if ! server_running; then
          echo "hally: herdr server failed to start" >&2
          exit 1
        fi
      fi

      attach() {
        if [[ "$ATTACH" == "1" ]]; then
          exec herdr
        fi
        exit 0
      }

      if [[ -z "$TARGET" ]]; then
        TARGET="$(
          {
            find "$HOME/workspace" -mindepth 1 -maxdepth 2 -type d 2>/dev/null
            find "$HOME" -mindepth 1 -maxdepth 1 -type d 2>/dev/null
            find "$HOME/.config" -mindepth 1 -maxdepth 1 -type d 2>/dev/null
          } \
            | sort -u \
            | fzf \
              --header-first \
              --header="Launch Project" \
              --prompt="🗡️  " \
              --preview 'eza --tree --icons --color=always --level 3 --git-ignore {}'
        )" || exit 0
      fi

      [[ -n "$TARGET" ]] || exit 0

      TARGET="$(cd "$TARGET" && pwd -P)"
      ROOT="$(git -C "$TARGET" rev-parse --show-toplevel 2>/dev/null || printf '%s\n' "$TARGET")"
      NAME="$(basename "$ROOT")"

      existing="$(
        herdr pane list \
          | jq -r --arg cwd "$ROOT" '[.result.panes[] | select(.cwd == $cwd)][0].workspace_id // empty'
      )"
      if [[ -n "$existing" ]]; then
        herdr workspace focus "$existing" >/dev/null
        attach
      fi

      workspace_id="$(
        herdr workspace create --cwd "$ROOT" --label "$NAME" --focus \
          | jq -r .result.workspace.workspace_id
      )"
      herdr-tally-layout --workspace "$workspace_id"
      attach
    '';
  };

  # Opens a new focused tab in the active workspace and runs a command in it.
  # Used by the vellum command palette (popups export HERDR_ACTIVE_*).
  herdrOpenTab = pkgs.writeShellApplication {
    name = "herdr-open-tab";
    runtimeInputs = [ pkgs.jq ];
    text = ''
      if [[ $# -lt 1 ]]; then
        echo "Usage: herdr-open-tab LABEL [COMMAND]" >&2
        exit 2
      fi

      ${herdrFn}

      label="$1"
      command="''${2:-}"
      args=(--label "$label" --focus)
      workspace="''${HERDR_ACTIVE_WORKSPACE_ID:-''${HERDR_WORKSPACE_ID:-}}"
      [[ -n "$workspace" ]] && args+=(--workspace "$workspace")
      [[ -n "''${HERDR_ACTIVE_PANE_CWD:-}" ]] && args+=(--cwd "$HERDR_ACTIVE_PANE_CWD")

      pane="$(herdr tab create "''${args[@]}" | jq -r .result.root_pane.pane_id)"
      if [[ -n "$command" ]]; then
        herdr pane run "$pane" "$command" >/dev/null
      fi
    '';
  };
in
{
  home.packages = [
    herdrOpenTab
    herdrTally
    herdrTallyLayout
  ];

  # Lives in conf.d so ~/.config/mise/config.toml stays writable for `mise use -g`.
  xdg.configFile."mise/conf.d/herdr.toml".text = ''
    [tools]
    herdr = "latest"
    "github:dkarter/hwt" = "latest"
    "github:dkarter/vellum" = "latest"
  '';

  # Out-of-store symlink: Herdr's settings UI and onboarding write to this file,
  # so keep it writable and let those edits land in the repo (synced via git).
  xdg.configFile."herdr/config.toml".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/nix-darwin/home/herdr/config.toml";

  xdg.configFile."hwt/config.yaml".source = ./hwt.yaml;

  # vlm resolves a relative source.file against the palette's real path, which
  # is in the nix store, so point it at the data file's absolute path instead.
  xdg.configFile."vellum/palettes/herdr-commands.toml".text =
    builtins.replaceStrings
      [ ''file = "../data/herdr-commands.toml"'' ]
      [ ''file = "${config.xdg.configHome}/vellum/data/herdr-commands.toml"'' ]
      (builtins.readFile ./vellum/herdr-commands.toml);
  xdg.configFile."vellum/data/herdr-commands.toml".source = ./vellum/herdr-commands-items.toml;

  programs.zsh.initContent = ''
    if command -v herdr > /dev/null 2>&1; then source <(herdr completion zsh); fi
  '';
}
