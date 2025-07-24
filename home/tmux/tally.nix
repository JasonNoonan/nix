{ pkgs, ... }:
pkgs.writeShellScriptBin "tally" ''
  set -eu
  TARGET=$(ls -d ~/workspace/* ~/* ~/.config/* | ${pkgs.fzf}/bin/fzf --header-first --header="Launch Project" --prompt="🗡️  " --preview '${pkgs.eza}/bin/eza --tree --icons --color=always --level 3 --git-ignore {}')
  NAME=$(basename $TARGET)
  SESSION_NAME=$(echo $NAME | tr [:lower:] [:upper:])
  SESSION_EXISTS=$(tmux has-session -t "$SESSION_NAME" 2>/dev/null && echo "true" || echo "false")
  IN_TMUX=$([[ -n "$TMUX" ]] && echo "true" || echo "false")

  SCRIPT="tmux_$NAME"
  if command -v $SCRIPT > /dev/null 2>&1; then
    $SCRIPT $TARGET $SESSION_NAME $SESSION_EXISTS $IN_TMUX
  else
    cd $TARGET
    tmux_session_rally $SESSION_NAME $SESSION_EXISTS $IN_TMUX
  fi
''
