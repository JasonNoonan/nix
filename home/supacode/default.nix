{ pkgs, ... }:

let
  supacodeCli = pkgs.writeShellApplication {
    name = "supacode";
    text = ''
      app_cli="/Applications/supacode.app/Contents/Resources/bin/supacode"
      if [[ -x "$app_cli" ]]; then
        exec "$app_cli" "$@"
      fi

      installed_cli="/usr/local/bin/supacode"
      if [[ -x "$installed_cli" ]]; then
        exec "$installed_cli" "$@"
      fi

      echo "supacode CLI not found. Install the Supacode app or enable its CLI from Supacode settings." >&2
      exit 127
    '';
  };

  supacodeTallyLayout = pkgs.writeShellApplication {
    name = "supacode-tally-layout";
    runtimeInputs = [
      pkgs.coreutils
      pkgs.gnused
      supacodeCli
    ];
    text = ''
      set -euo pipefail

      WORKTREE_ID=""
      TAB_ID=""
      SURFACE_ID=""
      FORCE=0
      AGENT_COMMAND="claude --dangerously-skip-permissions"

      if [[ -v SUPACODE_TALLY_FORCE ]]; then
        FORCE="$SUPACODE_TALLY_FORCE"
      fi

      if [[ -v SUPACODE_TALLY_AGENT ]]; then
        AGENT_COMMAND="$SUPACODE_TALLY_AGENT"
      fi

      while [[ $# -gt 0 ]]; do
        case "$1" in
          -w|--worktree)
            [[ $# -ge 2 ]] || { echo "missing value for $1" >&2; exit 2; }
            WORKTREE_ID="$2"
            shift 2
            ;;
          -t|--tab)
            [[ $# -ge 2 ]] || { echo "missing value for $1" >&2; exit 2; }
            TAB_ID="$2"
            shift 2
            ;;
          -s|--surface)
            [[ $# -ge 2 ]] || { echo "missing value for $1" >&2; exit 2; }
            SURFACE_ID="$2"
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
      Usage: supacode-tally-layout [--worktree ID --tab UUID --surface UUID] [--force] [--agent CMD]

      Seeds the current Supacode worktree with a tally-like layout:
      agent tab, nvim tab, scratch tab with a shell split, DBUI tab, and lazygit tab.

      Without explicit IDs it must run inside a Supacode terminal.
      USAGE
            exit 0
            ;;
          *)
            echo "unknown option: $1" >&2
            exit 2
            ;;
        esac
      done

      if [[ -z "$WORKTREE_ID" && -v SUPACODE_WORKTREE_ID ]]; then
        WORKTREE_ID="$SUPACODE_WORKTREE_ID"
      fi
      if [[ -z "$TAB_ID" && -v SUPACODE_TAB_ID ]]; then
        TAB_ID="$SUPACODE_TAB_ID"
      fi
      if [[ -z "$SURFACE_ID" && -v SUPACODE_SURFACE_ID ]]; then
        SURFACE_ID="$SUPACODE_SURFACE_ID"
      fi

      if [[ -z "$WORKTREE_ID" || -z "$TAB_ID" || -z "$SURFACE_ID" ]]; then
        echo "supacode-tally-layout needs worktree, tab, and surface IDs." >&2
        echo "Run it inside Supacode or pass --worktree, --tab, and --surface." >&2
        exit 2
      fi

      strip_ansi() {
        sed -E $'s/\x1b\\[[0-9;]*m//g'
      }

      clean_id() {
        strip_ansi | tr -d '\r\n'
      }

      tab_count="$(
        supacode tab list -w "$WORKTREE_ID" \
          | strip_ansi \
          | sed '/^[[:space:]]*$/d' \
          | wc -l \
          | tr -d '[:space:]'
      )"

      if [[ "$tab_count" -gt 1 && "$FORCE" != "1" ]]; then
        echo "Supacode worktree already has $tab_count tabs; leaving the existing layout intact." >&2
        echo "Re-run with --force to append the tally layout anyway." >&2
        exit 0
      fi

      new_tab() {
        local input="$1"
        supacode tab new -w "$WORKTREE_ID" -i "$input" | clean_id
      }

      new_split() {
        local tab="$1"
        local direction="$2"
        supacode surface split -w "$WORKTREE_ID" -t "$tab" -s "$tab" -d "$direction" | clean_id
      }

      nvim_tab="$(new_tab "nvim")"
      scratch_tab="$(new_tab "nvim scratchpad.ex")"
      new_split "$scratch_tab" "v" >/dev/null
      db_tab="$(new_tab "nvim +DBUI")"
      git_tab="$(new_tab "lazygit")"

      supacode tab focus -w "$WORKTREE_ID" -t "$TAB_ID"
      supacode surface focus -w "$WORKTREE_ID" -t "$TAB_ID" -s "$SURFACE_ID" -i "$AGENT_COMMAND"

      printf 'Seeded Supacode layout: agent=%s nvim=%s scratch=%s db=%s git=%s\n' \
        "$TAB_ID" "$nvim_tab" "$scratch_tab" "$db_tab" "$git_tab"
    '';
  };

  supacodeTally = pkgs.writeShellApplication {
    name = "supacode-tally";
    runtimeInputs = [
      pkgs.coreutils
      pkgs.eza
      pkgs.findutils
      pkgs.fzf
      pkgs.git
      pkgs.gnused
      pkgs.python3
      supacodeCli
      supacodeTallyLayout
    ];
    text = ''
      set -euo pipefail

      TARGET=""
      FORCE_ARGS=()

      while [[ $# -gt 0 ]]; do
        case "$1" in
          --force)
            FORCE_ARGS+=(--force)
            shift
            ;;
          -h|--help)
            cat <<'USAGE'
      Usage: supacode-tally [--force] [PROJECT_DIR]

      Pick a project like tally, open it in Supacode, and seed a tally-like tab layout.
      USAGE
            exit 0
            ;;
          *)
            if [[ -n "$TARGET" ]]; then
              echo "only one PROJECT_DIR may be passed" >&2
              exit 2
            fi
            TARGET="$1"
            shift
            ;;
        esac
      done

      strip_ansi() {
        sed -E $'s/\x1b\\[[0-9;]*m//g'
      }

      clean_id() {
        strip_ansi | tr -d '\r\n'
      }

      decode_uri() {
        python3 -c 'import sys, urllib.parse; print(urllib.parse.unquote(sys.argv[1]))' "$1"
      }

      normalize_dir() {
        local dir="$1"
        if [[ ! -d "$dir" ]]; then
          echo "not a directory: $dir" >&2
          exit 2
        fi
        (cd "$dir" && pwd -P)
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
              --prompt="> " \
              --preview 'eza --tree --icons --color=always --level 3 --git-ignore {}'
        )"
      fi

      [[ -n "$TARGET" ]] || exit 0

      TARGET="$(normalize_dir "$TARGET")"
      ROOT="$(git -C "$TARGET" rev-parse --show-toplevel 2>/dev/null || printf '%s\n' "$TARGET")"
      ROOT="$(normalize_dir "$ROOT")"

      supacode repo open "$ROOT"

      find_worktree_id() {
        local wanted="$1"
        local line clean decoded

        while IFS= read -r line; do
          clean="$(printf '%s\n' "$line" | clean_id)"
          [[ -n "$clean" ]] || continue
          decoded="$(decode_uri "$clean")"
          if [[ "$decoded" == "$wanted" ]]; then
            printf '%s\n' "$clean"
            return 0
          fi
        done < <(supacode worktree list 2>/dev/null || true)

        return 1
      }

      WORKTREE_ID=""
      for ((i = 0; i < 80; i++)); do
        if WORKTREE_ID="$(find_worktree_id "$ROOT")"; then
          break
        fi
        sleep 0.25
      done

      if [[ -z "$WORKTREE_ID" ]]; then
        echo "Supacode opened $ROOT, but no matching worktree appeared." >&2
        echo "Known Supacode worktrees:" >&2
        supacode worktree list 2>/dev/null \
          | while IFS= read -r line; do
              clean="$(printf '%s\n' "$line" | clean_id)"
              [[ -n "$clean" ]] && decode_uri "$clean" >&2
            done
        exit 1
      fi

      supacode worktree focus -w "$WORKTREE_ID"

      first_tab() {
        supacode tab list -w "$WORKTREE_ID" 2>/dev/null \
          | clean_id \
          | sed '/^[[:space:]]*$/d' \
          | head -n 1
      }

      focused_tab() {
        supacode tab list -w "$WORKTREE_ID" -f 2>/dev/null \
          | clean_id \
          | sed '/^[[:space:]]*$/d' \
          | head -n 1
      }

      TAB_ID=""
      for ((i = 0; i < 20; i++)); do
        TAB_ID="$(focused_tab)"
        [[ -n "$TAB_ID" ]] || TAB_ID="$(first_tab)"
        [[ -n "$TAB_ID" ]] && break
        sleep 0.25
      done

      if [[ -z "$TAB_ID" ]]; then
        TAB_ID="$(supacode tab new -w "$WORKTREE_ID" -i ":" | clean_id)"
      fi

      focused_surface() {
        supacode surface list -w "$WORKTREE_ID" -t "$TAB_ID" -f 2>/dev/null \
          | clean_id \
          | sed '/^[[:space:]]*$/d' \
          | head -n 1
      }

      first_surface() {
        supacode surface list -w "$WORKTREE_ID" -t "$TAB_ID" 2>/dev/null \
          | clean_id \
          | sed '/^[[:space:]]*$/d' \
          | head -n 1
      }

      SURFACE_ID=""
      for ((i = 0; i < 20; i++)); do
        SURFACE_ID="$(focused_surface)"
        [[ -n "$SURFACE_ID" ]] || SURFACE_ID="$(first_surface)"
        [[ -n "$SURFACE_ID" ]] && break
        sleep 0.25
      done

      if [[ -z "$SURFACE_ID" ]]; then
        SURFACE_ID="$TAB_ID"
      fi

      supacode-tally-layout -w "$WORKTREE_ID" -t "$TAB_ID" -s "$SURFACE_ID" "''${FORCE_ARGS[@]}"
    '';
  };

  supacodeTallyInstallRepo = pkgs.writeShellApplication {
    name = "supacode-tally-install-repo";
    runtimeInputs = [
      pkgs.coreutils
      pkgs.git
      pkgs.jq
    ];
    text = ''
      set -euo pipefail

      TARGET="."
      while [[ $# -gt 0 ]]; do
        case "$1" in
          -h|--help)
            echo "Usage: supacode-tally-install-repo [PROJECT_DIR]"
            exit 0
            ;;
          *)
            if [[ "$TARGET" != "." ]]; then
              echo "only one PROJECT_DIR may be passed" >&2
              exit 2
            fi
            TARGET="$1"
            shift
            ;;
        esac
      done

      if [[ ! -d "$TARGET" ]]; then
        echo "not a directory: $TARGET" >&2
        exit 2
      fi

      TARGET="$(cd "$TARGET" && pwd -P)"
      ROOT="$(git -C "$TARGET" rev-parse --show-toplevel 2>/dev/null || printf '%s\n' "$TARGET")"
      ROOT="$(cd "$ROOT" && pwd -P)"
      SETTINGS="$ROOT/supacode.json"
      TMP="$(mktemp)"

      if [[ -f "$SETTINGS" ]]; then
        jq '
          .setupScript = "supacode-tally-layout"
          | .archiveScript //= ""
          | .deleteScript //= ""
          | .openActionID //= "auto"
          | .scripts //= []
        ' "$SETTINGS" > "$TMP"
      else
        jq -n '{
          setupScript: "supacode-tally-layout",
          archiveScript: "",
          deleteScript: "",
          openActionID: "auto",
          scripts: []
        }' > "$TMP"
      fi

      mv "$TMP" "$SETTINGS"
      echo "Configured $SETTINGS to seed the Supacode tally layout for new worktrees."
    '';
  };
in
{
  home.packages = [
    supacodeCli
    supacodeTally
    supacodeTallyInstallRepo
    supacodeTallyLayout
  ];
}
