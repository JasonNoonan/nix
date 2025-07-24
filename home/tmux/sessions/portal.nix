{ pkgs, ... }:
pkgs.writeShellScriptBin "tmux_portal" ''
  #! bash
  set -eu
  
  source tmux-shared

  TARGET=$1
  SESSION_NAME=$2
  SESSION_EXISTS=$3
  IN_TMUX=$4

  cd $TARGET
  docker compose up -d
  get-tmux-session $SESSION_NAME $SESSION_EXISTS $IN_TMUX
  docker compose stop
''
