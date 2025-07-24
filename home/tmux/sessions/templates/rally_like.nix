{ pkgs, ... }:
pkgs.writeShellScriptBin "tmux_session_rally" ''
  #! bash
  set -eu
  SESSION_NAME=$1

  NVIM_ICON=" "
  TERMINAL_ICON=" "
  DB_ICON=" "
  GIT_ICON=""
  ROBOT_ICON=""

  ${pkgs.tmux}/bin/tmux new-session -ADXd -x $(tput cols) -y $(tput lines) -n $NVIM_ICON -s $SESSION_NAME
  ${pkgs.tmux}/bin/tmux send-keys "nvim" Enter

  ${pkgs.tmux}/bin/tmux new-window -a -n $TERMINAL_ICON
  ${pkgs.tmux}/bin/tmux send-keys "nvim scratchpad.ex" Enter
  ${pkgs.tmux}/bin/tmux split-window -v -p 30

  ${pkgs.tmux}/bin/tmux new-window -a -n $ROBOT_ICON
  ${pkgs.tmux}/bin/tmux send-keys "opencode" Enter

  ${pkgs.tmux}/bin/tmux new-window -a -n $DB_ICON
  ${pkgs.tmux}/bin/tmux send-keys "nvim +DBUI" Enter

  ${pkgs.tmux}/bin/tmux new-window -a -n $GIT_ICON
  ${pkgs.tmux}/bin/tmux send-keys "lazygit" Enter

  ${pkgs.tmux}/bin/tmux select-window -t 1
  ${pkgs.tmux}/bin/tmux attach-session -t $SESSION_NAME
''
