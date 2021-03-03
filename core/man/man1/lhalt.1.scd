lhalt(1)

# NAME

lhalt - halt machines of a netkit lab

# SYNOPSIS

*lhalt* \[options\] \[_MACHINE-NAME_\...\]

# DESCRIPTION

The _lhalt_ command can be used to gracefully shut down virtual machines
of a Netkit lab. *lhalt* makes use of *vhalt* to halt virtual machines
(see *vhalt*(1)).

By default, _vhalt_ stops all the virtual machines of the lab. If a list
of *MACHINE-NAME*s is provided, then only virtual machines with a
matching name *and* that are part of the lab will be halted.

The following options are supported by _lhalt_:

*-d* _DIRECTORY_
	Halt the Netkit lab that is located inside *DIRECTORY*. If no *-d*
	option is provided, *lhalt* assumes that the lab is located in the
	current directory. The path to the lab directory (being that the
	current directory or one provided by *-d*) must never contain
	spaces.

*-l*, *--list*
	Show a list of currently running virtual machines after the lab has
	been halted. This is useful to check whether all the hosts have been
	shut down.

*-q*, *--quick*, *--quiet*
	This option prevents *lhalt* from checking whether virtual machines
	have properly halted. Hence, it speeds up the halt process. Notice
	that, unlike *lcrash* (see *lcrash*(1)), a shutdown fails or
	succeeds regardless of the use of this option (i.e., no benefit is
	gained from retrying without this option). This option slightly
	reduces the output of *lhalt* as well.\
	This option is incompatible with *-r* or *--remove-fs*.

*-r*, *--remove-fs*
	Delete virtual machines (COW) filesystems (.disk files) after
	halting the corresponding machines. Default action is to keep the
	filesystems, so that the lab can be restarted while preserving
	filesystem contents.\
	Using this option never affects the model filesystem. This option is
	incompatible with *-q* (*--quick*, *--quiet*).

	See the README in the Netkit filesystem package for information about
	COW and model filesystems.

The following standard options are also supported.

*-h*, *--help*
	Show usage information.

*--version*
	Print information about the installed Netkit release and the host
	kernel version and exit. If \`\`_\<unavailable\>_\'\' is printed
	instead of a version number, then the corresponding information
	could not be retrieved (for example because a non-standard Netkit
	kernel or filesystem is being used).

# ENVIRONMENT VARIABLES

All Netkit commands require that the *NETKIT\_HOME* variable contains
the name of the directory Netkit is installed in.

Apart from this, *lhalt* supports no other environment variables.

# SEE ALSO

*lstart*(1), *lclean*(1), *lcrash*(1), *lrestart*(1), *linfo*(1),
*ltest*(1), *vhalt*(1), Netkit filesystem README.

# AUTHOR

*lhalt* script: Stefano Pettini, Massimo Rimondini\
This man page: Fabio Ricci, Massimo Rimondini
