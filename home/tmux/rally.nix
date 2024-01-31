{ pkgs, ...}:
pkgs.writeShellScriptBin "rally" ''
  set -eu
  TARGET=$(ls -d ~/workspace/* ~/* ~/.config/* | ${pkgs.fzf}/bin/fzf --header-first --header="Launch Project" --prompt="🗡️  " --preview '${pkgs.eza}/bin/eza --tree --icons --color=always --level 3 --git-ignore {}')
  NAME=$(basename $TARGET)
  SESSION_NAME=$(echo $NAME | tr [:lower:] [:upper:])

  ${pkgs.smug}/bin/smug start $NAME --debug -a 2>/dev/null || ${pkgs.smug}/bin/smug start default name=$SESSION_NAME root=$TARGET --debug -a
''
