#! bash
set -eu
TARGET=$1
SESSION_NAME=$2

cd $TARGET
tmux new-session -ADXd -x $(tput cols) -y $(tput lines) -n " " -s $SESSION_NAME "nvim"
tmux new-window -a -n " " "nvim scratchpad.ex"
tmux new-window -a -n " " "nvim +DBUI"
tmux new-window -a -n "" "lazygit"

tmux select-window -t " "
tmux split-window -v -p 30
                                    
tmux select-window -t " "
tmux attach-session -t $SESSION_NAME
