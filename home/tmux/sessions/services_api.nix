{ pkgs, ... }:
pkgs.writeShellScriptBin "tmux_services_api" ''
  #! bash
  set -eu
  
  source tmux-shared

  TARGET=$1
  SESSION_NAME=$2
  SESSION_EXISTS=$3
  IN_TMUX=$4

  cd $TARGET
  get-tmux-session $SESSION_NAME $SESSION_EXISTS $IN_TMUX
''
