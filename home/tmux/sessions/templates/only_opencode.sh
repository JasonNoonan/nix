#! bash
set -eu
TARGET=$1
SESSION_NAME=$2

cd $TARGET
tmux new-session -ADXd -x $(tput cols) -y $(tput lines) -n "" -s $SESSION_NAME "opencode"
tmux split-window -h -p 25 "lazygit"
tmux split-window -v -p 25
tmux select-pane -t 2
tmux send-keys "2++"
tmux select-pane -t 1

tmux select-window -t ""
tmux attach-session -t $SESSION_NAME
