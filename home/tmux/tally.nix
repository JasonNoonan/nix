{ pkgs, ... }:
pkgs.writeShellScriptBin "tally" ''
  set -e

  TARGET=$(ls -d ~/workspace/* ~/* ~/.config/* | ${pkgs.fzf}/bin/fzf --header-first --header="Launch Project" --prompt="🗡️  " --preview '${pkgs.eza}/bin/eza --tree --icons --color=always --level 3 --git-ignore {}')
  NAME=$(basename $TARGET)
  SESSION_NAME=$(echo $NAME | tr [:lower:] [:upper:] | sed 's/\./-/g')
  SESSION_EXISTS=$(tmux has-session -t "$SESSION_NAME" 2>/dev/null && echo "true" || echo "false")
  echo "Session $SESSION_NAME exists?: $SESSION_EXISTS"
  IN_TMUX=$([[ -n "$TMUX" ]] && echo "true" || echo "false")

  NVIM_ICON=" "
  TERMINAL_ICON=" "
  DB_ICON=" "
  GIT_ICON=""
  ROBOT_ICON=""

  DETACH=false
  while getopts "d" opt; do
    case $opt in
      d)
        DETACH=true
        ;;
      \?)
        echo "Invalid option: -$OPTARG" >&2
        exit 1
        ;;
    esac
  done

  function attach-or-switch() {
    if [[ $DETACH == true ]]; then
      ${pkgs.tmux}/bin/tmux switch-client -t "$SESSION_NAME" 
    else
      ${pkgs.tmux}/bin/tmux attach-session -t "$SESSION_NAME"
    fi
  }

  function tmux-session-full() {
    ${pkgs.tmux}/bin/tmux new-session -ADd -x $(tput cols) -y $(tput lines) -n "$ROBOT_ICON" -s $SESSION_NAME
    ${pkgs.tmux}/bin/tmux send-keys -t "$SESSION_NAME:$ROBOT_ICON.1" "claude" Enter
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
    attach-or-switch
  }

  function tmux-session-ai-agent() {
    ${pkgs.tmux}/bin/tmux new-session -ADd -x $(tput cols) -y $(tput lines) -n "$ROBOT_ICON" -s $SESSION_NAME
    ${pkgs.tmux}/bin/tmux send-keys -t "$SESSION_NAME:$ROBOT_ICON" "claude" Enter
    ${pkgs.tmux}/bin/tmux split-window -h -p 25 
    ${pkgs.tmux}/bin/tmux send-keys "lazygit" Enter
    ${pkgs.tmux}/bin/tmux split-window -v -p 25
    ${pkgs.tmux}/bin/tmux select-pane -t 2
    ${pkgs.tmux}/bin/tmux send-keys "2++"
    ${pkgs.tmux}/bin/tmux select-pane -t 1
    attach-or-switch
  }

  function tmux-session-rally() {
    ${pkgs.tmux}/bin/tmux new-session -ADd -x $(tput cols) -y $(tput lines) -n $NVIM_ICON -s $SESSION_NAME
    ${pkgs.tmux}/bin/tmux send-keys "nvim" Enter

    ${pkgs.tmux}/bin/tmux new-window -a -n $TERMINAL_ICON

    ${pkgs.tmux}/bin/tmux new-window -a -n $ROBOT_ICON
    ${pkgs.tmux}/bin/tmux send-keys "claude" Enter

    ${pkgs.tmux}/bin/tmux new-window -a -n $DB_ICON
    ${pkgs.tmux}/bin/tmux send-keys "nvim +DBUI" Enter

    ${pkgs.tmux}/bin/tmux new-window -a -n $GIT_ICON
    ${pkgs.tmux}/bin/tmux send-keys "lazygit" Enter

    ${pkgs.tmux}/bin/tmux select-window -t 1
    attach-or-switch
  }

  function new-tmux-session() {
    case $SESSION_NAME in
      JANUS|PORTAL)
        cd $TARGET
        
        docker compose up -d
        tmux-session-full
        docker compose stop
        ;;


      SOME_FUTURE_PROJECT|DOESNT_EXIST_YET)
        cd $TARGET
        tmux-session-ai-agent
        ;;

      NEXUS_WRAPPER|POINT_QUEST|SERVICES_API|TUNEZ|MUG_TRACKER|BALENCIAUTHGA)
        # ease of use in case I need to swap the profile these call
        # cd $TARGET
        # tmux-session-full
        ;&

      *)
        cd $TARGET
        # tmux-session-rally
        tmux-session-full
        ;;
    esac
  }
    
  if [[ "$SESSION_EXISTS" == "true" ]]; then
    [[ "$IN_TMUX" == "true" ]] && ${pkgs.tmux}/bin/tmux switch-client -t "$SESSION_NAME" || new-tmux-session
  else
    new-tmux-session
  fi
''
