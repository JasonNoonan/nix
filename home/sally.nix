{ pkgs, ... }:

let
  sally = pkgs.writeShellScriptBin "sally" ''
    set -eu
    TARGET=$(ls -d ~/workspace/* ~/workspace/*/* ~/* ~/.config/* 2>/dev/null | ${pkgs.fzf}/bin/fzf --header-first --header="Launch Sidecar" --prompt="🗡️  " --preview '${pkgs.eza}/bin/eza --tree --icons --color=always --level 3 --git-ignore {}')
    cd "$TARGET"
    exec sidecar
  '';
in
{
  home.packages = [ sally ];
}
