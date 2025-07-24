{ pkgs, ... }:
pkgs.writeShellScriptBin "tally" ''
  set -eu
  TARGET=$(ls -d ~/workspace/* ~/* ~/.config/* | ${pkgs.fzf}/bin/fzf --header-first --header="Launch Project" --prompt="🗡️  " --preview '${pkgs.eza}/bin/eza --tree --icons --color=always --level 3 --git-ignore {}')
  NAME=$(basename $TARGET)
  SESSION_NAME=$(echo $NAME | tr [:lower:] [:upper:])

  SCRIPT="tmux_$NAME"
  if command -v $SCRIPT > /dev/null 2>&1; then
    $SCRIPT $TARGET $SESSION_NAME
  else
    cd $TARGET
    tmux_session_rally $SESSION_NAME
  fi
''
