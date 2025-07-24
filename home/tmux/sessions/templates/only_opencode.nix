{ pkgs, ... }:
pkgs.writeShellScriptBin "tmux_session_opencode" ''
  #! bash
  set -eu
  SESSION_NAME=$1

  NVIM_ICON=" "
  TERMINAL_ICON=" "
  DB_ICON=" "
  GIT_ICON=""
  ROBOT_ICON=""

  ${pkgs.tmux}/bin/tmux new-session -ADXd -x $(tput cols) -y $(tput lines) -n "$ROBOT_ICON" -s $SESSION_NAME
  ${pkgs.tmux}/bin/tmux send-keys -t "$SESSION_NAME:$ROBOT_ICON" "opencode" Enter
  ${pkgs.tmux}/bin/tmux split-window -h -p 25 
  ${pkgs.tmux}/bin/tmux send-keys "lazygit" Enter
  ${pkgs.tmux}/bin/tmux split-window -v -p 25
  ${pkgs.tmux}/bin/tmux select-pane -t 2
  ${pkgs.tmux}/bin/tmux send-keys "2++"
  ${pkgs.tmux}/bin/tmux select-pane -t 1

  ${pkgs.tmux}/bin/tmux select-window -t "$ROBOT_ICON"
  ${pkgs.tmux}/bin/tmux attach-session -t "$SESSION_NAME"
''
