vcommand(1)

# NAME

vcommand - send a command to a netkit virtual machine through its tmux session.

# SYNOPSIS

*vcommand* -m _MACHINE-NAME_ --timeout 10 --command ping -c1 127.0.0.1

# DESCRIPTION

_vcommand_ will use the tmux send-keys command to type the command into
the tmux session for the machine. It will then wait for the time
specified by timeout, then read any new text that has appeared in the
tmux session, and print this.

Note that there is only one shell instance in tmux, so sending multiple
commands at once / sending commands while the tmux session is being
actively used may result in undesirable behaviour. vcommand gives you
access to the input and output of the machines tty, and not an instance
of a shell to execute commands in.

# OPTIONS

*-h*,
*--help*
	Print help message and exit. Other arguments will be ignored.

*-v*,
*--verbose*
	Set the VERBOSE variable to TRUE so it can be used for adding
	debugging echo statements in the vcommand script.

*-m* _MACHINENAME_,
*--machine* _MACHINENAME_
	Name of the netkit machine to send the command to.

*-n* _N_
*--timeout* _N_
	Wait N seconds after entering the command to the tmux before
	grabbing any new output from the tmux session.

	The default value for this is 1 second.

	As we don't have an interactive shell we don't know when a command has
	finished executing. Therefore we have to choose how long we are going to
	wait before grabbing any new output.

*-c* _COMMAND_,
*--command* _COMMAND_
	Command to send to the tmux session. This should always be the last
	argument given to vcommand. Anything that follows this will be taken
	as one string and sent to the tmux session.

# ENVIRONMENT VARIABLES

All Netkit commands require that the *NETKIT\_HOME* variable contains
the name of the directory Netkit is installed in.

Apart from this, _vcommand_ supports no other environment variables.

# SEE ALSO

_vclean_(1), _vconf_(1), _vcrash_(1), _vhalt_(1), _vlist_(1),
_vconnect_(1), _vstart_(1).

# AUTHOR

_vcommand_ script: Billy Bromell

This man page: Billy Bromell
