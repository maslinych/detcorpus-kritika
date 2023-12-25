#!/bin/sh
root_dir="$1"
shift
environment="$1"
shift
tmux has-session -t "$environment" && echo "$environment already running" && exit 0
tmux new-session -d -s "$environment" "export share_network=1 ; hsh-shell --root --mount=/proc $root_dir/$environment"
sleep 5
tmux send-keys -t "$environment":0 "service httpd2 start" Enter
tmux send-keys -t "$environment":0 "/usr/lib/python3/site-packages/bonito/jobrunner.py -d /var/lib/ske/jobs -n localhost -p 8333 -e root@localhost -l /var/lib/ske/jobs/jobs.log -f localhost &" Enter
