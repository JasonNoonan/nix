{ pkgs, ... }:
pkgs.writeShellScriptBin "tmux_session_full" ''
  #! bash
  set -eu
  SESSION_NAME=$1

  NVIM_ICON=" "
  TERMINAL_ICON=" "
  DB_ICON=" "
  GIT_ICON=""
  ROBOT_ICON=""

  ${pkgs.tmux}/bin/tmux new-session -ADXd -x $(tput cols) -y $(tput lines) -n "$ROBOT_ICON" -s $SESSION_NAME
  ${pkgs.tmux}/bin/tmux send-keys -t "$SESSION_NAME:$ROBOT_ICON.0" "opencode" Enter
  ${pkgs.tmux}/bin/tmux split-window -h -p 25
  ${pkgs.tmux}/bin/tmux send-keys -t "$SESSION_NAME:$ROBOT_ICON.1" "lazygit" Enter
  ${pkgs.tmux}/bin/tmux split-window -v -p 25 
  ${pkgs.tmux}/bin/tmux send-keys -t "$SESSION_NAME:$ROBOT_ICON.2" "2++" Enter
  ${pkgs.tmux}/bin/tmux select-pane -t "$SESSION_NAME:$ROBOT_ICON.0"

  ${pkgs.tmux}/bin/tmux new-window -a -n "$NVIM_ICON"
  ${pkgs.tmux}/bin/tmux send-keys -t "$SESSION_NAME:$NVIM_ICON" "nvim" Enter

  ${pkgs.tmux}/bin/tmux new-window -a -n "$TERMINAL_ICON" 
  ${pkgs.tmux}/bin/tmux send-keys -t "$SESSION_NAME:$TERMINAL_ICON" "nvim scratchpad.ex" Enter
  ${pkgs.tmux}/bin/tmux split-window -t "$SESSION_NAME:$TERMINAL_ICON" -v -p 30

  ${pkgs.tmux}/bin/tmux new-window -a -n "$DB_ICON" 
  ${pkgs.tmux}/bin/tmux send-keys -t "$SESSION_NAME:$DB_ICON" "nvim +DBUI" Enter

  ${pkgs.tmux}/bin/tmux new-window -a -n "$GIT_ICON"
  ${pkgs.tmux}/bin/tmux send-keys -t "$SESSION_NAME:$GIT_ICON" "lazygit" Enter

  ${pkgs.tmux}/bin/tmux select-window -t "$ROBOT_ICON"
  ${pkgs.tmux}/bin/tmux attach-session -t "$SESSION_NAME"
''
