#!/bin/bash
####################################################################################
##
## This script is used to start external programs that should stop when the
## calling Elixir process aborts.
##
## Usage: start.sh <NAMED PIPE> <SIGNAL> <COMMAND>
##
## <NAMED PIPE>    Named pipe which will be monitored via `cat` waiting for EOF
## <SIGNAL>        Which signal to send to the child process when parent exits
## <COMMAND>       Command to execute. This command will be started in the background
##                 and will receive the provided signal on exit of parent
##
####################################################################################
# Watch named pipe passed in (This will hang until EOF received from Elixir process)
SCRIPT_PATH=$(dirname $(realpath -s $0))
$SCRIPT_PATH/watch_parent.sh $1 $2 $1_pid &
# Write PID file of parent process since Porcelain will wrap this script in a shell
echo $PPID > $1_pid
# Execute command
eval $3
