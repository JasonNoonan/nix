# herdr-favorites: star agent sessions and narrow Herdr's Agents sidebar panel
# to the starred ones. Run by the local.favorites Herdr plugin (see
# ./default.nix); `herdr-favorites sync` also works from any Herdr pane.
#
# A star is a `favorite` pane metadata token ("★" or "★ <note>"), which an
# agent.view.set filter turns into the panel's contents. Tokens and views only
# live as long as the server, so starred sessions are also saved by agent
# session id (survives Claude's session restore) and re-applied by `sync`.

PLUGIN_ID="${HERDR_PLUGIN_ID:-local.favorites}"
SOURCE="plugin:$PLUGIN_ID"
TOKEN=favorite
SOCKET="${HERDR_SOCKET_PATH:-$HOME/.config/herdr/herdr.sock}"
STATE_DIR="${HERDR_PLUGIN_STATE_DIR:-${XDG_STATE_HOME:-$HOME/.local/state}/herdr-favorites}"
STATE="$STATE_DIR/favorites.json"
LOCK="$STATE_DIR/.lock"

herdr() { "${HERDR_BIN_PATH:-herdr}" "$@"; }

usage() {
  cat <<'USAGE'
Usage: herdr-favorites COMMAND

  toggle [PANE]       unstar the pane's agent session, or prompt for a note and star it
  star PANE [NOTE]    star the pane's agent session
  unstar PANE         unstar the pane's agent session
  sync                re-apply saved stars and the Favorites panel view
  view                show only starred agents in the Agents panel
  clear-view          restore the normal Agents panel

PANE defaults to the focused pane from the plugin context, else $HERDR_PANE_ID.
USAGE
}

mkdir -p "$STATE_DIR"
[[ -s "$STATE" ]] || echo '{}' >"$STATE"

# Event hooks fire concurrently; serialize read-modify-write of the state file.
lock() {
  for _ in $(seq 50); do
    mkdir "$LOCK" 2>/dev/null && { trap 'rmdir "$LOCK" 2>/dev/null' EXIT; return 0; }
    sleep 0.1
  done
  # A crashed run left the lock behind; take it over.
  trap 'rmdir "$LOCK" 2>/dev/null' EXIT
}

api() {
  jq -cn "$@" | socat -t 2 - "UNIX-CONNECT:$SOCKET"
}

set_view() {
  api --arg source "$SOURCE" --arg token "$TOKEN" '{
    id: "favorites-view",
    method: "agent.view.set",
    params: {
      source: $source,
      label: "favorites",
      filter: {op: "exists", field: {token: $token}},
      sort: [{field: "workspace_order"}, {field: "tab_order"}, {field: "pane_order"}]
    }
  }' >/dev/null
}

target_pane() {
  local pane="${1:-}"
  if [[ -z "$pane" && -n "${HERDR_PLUGIN_CONTEXT_JSON:-}" ]]; then
    pane="$(jq -r '.focused_pane_id // .pane_id // empty' <<<"$HERDR_PLUGIN_CONTEXT_JSON")"
  fi
  pane="${pane:-${HERDR_PANE_ID:-}}"
  [[ -n "$pane" ]] || { echo "herdr-favorites: no pane to act on" >&2; exit 1; }
  printf '%s\n' "$pane"
}

# Prints the agent JSON for a pane, or nothing if it isn't hosting an agent.
agent_in() {
  herdr agent get "$1" 2>/dev/null | jq -c '.result.agent // empty'
}

notify() {
  local args=("$1")
  [[ -n "${2:-}" ]] && args+=(--body "$2")
  herdr notification show "${args[@]}" >/dev/null 2>&1 || true
}

set_token() {
  herdr pane report-metadata "$1" --source "$SOURCE" --token "$TOKEN=$2" >/dev/null
}

clear_token() {
  herdr pane report-metadata "$1" --source "$SOURCE" --clear-token "$TOKEN" >/dev/null
}

star() {
  local pane agent session label
  pane="$(target_pane "${1:-}")"
  agent="$(agent_in "$pane")"
  session="$(jq -r '.agent_session.value // empty' <<<"$agent")"
  if [[ -z "$session" ]]; then
    notify "Can't star $pane" "No agent session in that pane yet."
    exit 1
  fi
  label="★${2:+ $2}"
  lock
  jq --arg s "$session" --arg l "$label" '.[$s] = $l' "$STATE" >"$STATE.tmp" && mv "$STATE.tmp" "$STATE"
  set_token "$pane" "$label"
  set_view
}

unstar() {
  local pane session
  pane="$(target_pane "${1:-}")"
  session="$(agent_in "$pane" | jq -r '.agent_session.value // empty')"
  lock
  if [[ -n "$session" ]]; then
    jq --arg s "$session" 'del(.[$s])' "$STATE" >"$STATE.tmp" && mv "$STATE.tmp" "$STATE"
  fi
  clear_token "$pane"
}

toggle() {
  local pane agent session
  pane="$(target_pane "${1:-}")"
  agent="$(agent_in "$pane")"
  if [[ -z "$agent" ]]; then
    notify "Can't star $pane" "Only agent panes can be favorites."
    exit 1
  fi
  session="$(jq -r '.agent_session.value // empty' <<<"$agent")"
  if jq -e --arg t "$TOKEN" '.tokens[$t] // empty' <<<"$agent" >/dev/null \
    || jq -e --arg s "$session" 'has($s)' "$STATE" >/dev/null; then
    unstar "$pane"
    notify "Unstarred $pane"
  elif [[ -n "${HERDR_PLUGIN_ID:-}" ]]; then
    # Ask for a note in a popup (the "note" pane in the plugin manifest).
    herdr plugin pane open --plugin "$PLUGIN_ID" --entrypoint note --focus \
      --env "HERDR_FAVORITES_PANE=$pane" >/dev/null
  else
    note_prompt "$pane"
  fi
}

note_prompt() {
  local pane="${1:-${HERDR_FAVORITES_PANE:-}}" note
  pane="$(target_pane "$pane")"
  printf '★ Star %s\n\nNote, e.g. "priority" or "research" (enter to skip, ctrl-c to cancel):\n> ' "$pane"
  IFS= read -r note || exit 0
  star "$pane" "$note"
}

# Reconcile tokens with the saved sessions: restored sessions get their star
# back, and a starred pane whose agent started a new session (e.g. /clear)
# keeps its star under the new session id too.
sync() {
  local agents changes adopt
  lock
  agents="$(herdr agent list | jq -c '[.result.agents[] | select(.agent_session.value != null)]')"
  changes="$(
    jq -c --arg t "$TOKEN" --slurpfile state "$STATE" '
      .[]
      | (.tokens[$t] // "") as $tok
      | ($state[0][.agent_session.value] // "") as $saved
      | if $saved != "" and $tok == "" then {pane: .pane_id, set: $saved}
        elif $tok != "" and $saved == "" then {session: .agent_session.value, adopt: $tok}
        else empty end
    ' <<<"$agents"
  )"
  while IFS= read -r change; do
    [[ -n "$change" ]] || continue
    if jq -e 'has("set")' <<<"$change" >/dev/null; then
      set_token "$(jq -r .pane <<<"$change")" "$(jq -r .set <<<"$change")"
    fi
  done <<<"$changes"
  adopt="$(jq -sc 'map(select(has("adopt")) | {key: .session, value: .adopt}) | from_entries' <<<"$changes")"
  if [[ "$adopt" != "{}" ]]; then
    jq --argjson a "$adopt" '. + $a' "$STATE" >"$STATE.tmp" && mv "$STATE.tmp" "$STATE"
  fi
  # Re-installing the same view is a cheap no-op for the UI.
  if [[ "${HERDR_PLUGIN_EVENT:-}" == "" || "${HERDR_PLUGIN_EVENT:-}" == "startup" ]]; then
    set_view
  fi
}

case "${1:-}" in
  toggle) toggle "${2:-}" ;;
  star) star "${2:-}" "${3:-}" ;;
  unstar) unstar "${2:-}" ;;
  note) note_prompt "${2:-}" ;;
  sync) sync ;;
  view) set_view ;;
  clear-view) api --arg source "$SOURCE" '{id: "favorites-view", method: "agent.view.clear", params: {source: $source}}' >/dev/null ;;
  -h|--help|"") usage ;;
  *) usage >&2; exit 2 ;;
esac
