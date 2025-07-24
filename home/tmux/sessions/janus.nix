{ pkgs, ... }:
pkgs.writeShellScriptBin "tmux_janus" ''
  set -eu
  TARGET=$1
  SESSION_NAME=$2

  cd $TARGET
  docker compose up -d
  tmux_session_full $SESSION_NAME
  docker compose stop
''
