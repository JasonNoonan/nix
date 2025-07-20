{ pkgs, ... }:
pkgs.writeShellScriptBin "tally" ''
  set -eu
  TARGET=$(ls -d ~/workspace/* ~/* ~/.config/* | ${pkgs.fzf}/bin/fzf --header-first --header="Launch Project" --prompt="🗡️  " --preview '${pkgs.eza}/bin/eza --tree --icons --color=always --level 3 --git-ignore {}')
  NAME=$(basename $TARGET)
  SESSION_NAME=$(echo $NAME | tr [:lower:] [:upper:])

  if [[ -f "$HOME/.config/tmux_sessions/$NAME.sh" ]]; then
    $HOME/.config/tmux_sessions/${NAME}.sh $TARGET $SESSION_NAME
  else
    $HOME/.config/tmux_sessions/templates/rally_like.sh $TARGET $SESSION_NAME
  fi
''
