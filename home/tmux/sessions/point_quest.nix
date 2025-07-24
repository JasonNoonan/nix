{ pkgs, ... }:
pkgs.writeShellScriptBin "tmux_point_quest" ''
#! bash
set -eu
TARGET=$1
SESSION_NAME=$2

cd $TARGET
tmux_session_full $SESSION_NAME
''
