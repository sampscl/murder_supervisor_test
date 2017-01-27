#!/bin/bash
####################################################################################
##
## This script is used to watch external programs that should stop when the
## calling Elixir process aborts.  This is called by start.sh
##
## NOTE: This does not currently work for commands started with sudo as the `kill` will
## not be able to kill the child process
##
## Usage: watch_parent.sh <NAMED PIPE> <SIGNAL> <PID FILE>
##
## <NAMED PIPE>    Named pipe which will be monitored via `cat` waiting for EOF
## <SIGNAL>        Which signal to send to the child process when parent exits
## <PID FILE>      File containing PID of process that will receive the provided
##                 signal on exit of parent
##
####################################################################################
# Read named pipe which will block until Elixir process sends EOF
cat $1
# Kill parent group (note "-" in front of PID) with given signal
kill -s $2 -$(< $3)
