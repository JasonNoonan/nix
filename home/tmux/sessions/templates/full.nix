{ pkgs, ... }:
pkgs.writeShellScriptBin "tmux_session_full" ''
  #! bash
  set -eu
  SESSION_NAME=$1
  SESSION_EXISTS=$2
  IN_TMUX=$3

  function switch-tmux-session() {
    ${pkgs.tmux}/bin/tmux switch-client -t "$SESSION_NAME"
  }

  function new-tmux-session() {
    NVIM_ICON=" "
    TERMINAL_ICON=" "
    DB_ICON=" "
    GIT_ICON=""
    ROBOT_ICON=""
    
    ${pkgs.tmux}/bin/tmux new-session -ADXd -x $(tput cols) -y $(tput lines) -n "$ROBOT_ICON" -s $SESSION_NAME
    ${pkgs.tmux}/bin/tmux send-keys -t "$SESSION_NAME:$ROBOT_ICON.1" "opencode" Enter
    ${pkgs.tmux}/bin/tmux split-window -h -p 25
    ${pkgs.tmux}/bin/tmux send-keys -t "$SESSION_NAME:$ROBOT_ICON.2" "lazygit" Enter
    ${pkgs.tmux}/bin/tmux send-keys -t "$SESSION_NAME:$ROBOT_ICON.2" "2++" Enter
    ${pkgs.tmux}/bin/tmux split-window -v -p 25 
    ${pkgs.tmux}/bin/tmux send-keys -t "$SESSION_NAME:$ROBOT_ICON.3" "clear" Enter

    ${pkgs.tmux}/bin/tmux new-window -a -n "$NVIM_ICON"
    ${pkgs.tmux}/bin/tmux send-keys -t "$SESSION_NAME:$NVIM_ICON" "nvim" Enter

    # intentionally create this as a 'kills pane on close' session
    ${pkgs.tmux}/bin/tmux new-window -a -n "$TERMINAL_ICON" "nvim scratchpad.ex"
    ${pkgs.tmux}/bin/tmux split-window -t "$SESSION_NAME:$TERMINAL_ICON" -v -p 30

    ${pkgs.tmux}/bin/tmux new-window -a -n "$DB_ICON" 
    ${pkgs.tmux}/bin/tmux send-keys -t "$SESSION_NAME:$DB_ICON" "nvim +DBUI" Enter

    ${pkgs.tmux}/bin/tmux new-window -a -n "$GIT_ICON"
    ${pkgs.tmux}/bin/tmux send-keys -t "$SESSION_NAME:$GIT_ICON" "lazygit" Enter

    ${pkgs.tmux}/bin/tmux select-window -t "$ROBOT_ICON"
    ${pkgs.tmux}/bin/tmux select-pane -t "$SESSION_NAME:$ROBOT_ICON.1"
    ${pkgs.tmux}/bin/tmux attach-session -t "$SESSION_NAME"
  }

  if [[ "$SESSION_EXISTS" == "true" ]]; then 
    [[ "$IN_TMUX" == "true" ]] && switch-tmux-session || new-tmux-session
  else
    new-tmux-session
  fi
''
