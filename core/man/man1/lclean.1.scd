lclean(1)

# NAME

lclean - clean temporary files created after launching netkit lab

# SYNOPSIS

*lclean* \[options\] \[_MACHINE-NAME_\...\]

# DESCRIPTION

**lclean** can be used to delete temporary files that have been created
while running a Netkit lab. Some of the them are specific for each
virtual machine, while others are unique for the whole lab. Some are
written inside the directory from which _lstart_ has been invoked, while
others are placed inside the lab directory.\
Assuming that _lab-path_ is the directory where the lab is located,
*lclean* deletes the following files, if found to exist:

- ./_machine-name_.ready
- ./_machine-name_.disk
- ./_machine-name_.log (no longer produced by latest releases, but still removed for backwards compatibility)
- _lab-path_/readyfor.test

If invoked with no arguments, *lclean* removes temporary files for all
the virtual machines that make up the lab (i.e., _machine-name_ is
replaced by the name of each virtual machine). It is also possible to
provide a list of *MACHINE\-NAME*s, in which case _lclean_ just removes
temporary files for those virtual machines (as well as the `readyfor.test`
file).

Removing virtual machines COW filesystems (.disk files) implies that
virtual machines contents are reverted to their original state when the
lab is restarted. Of course, any persistent part of the lab is
preserved, including those files that are automatically copied inside
virtual machines during the boot phase.

See the README file in the Netkit filesystem package for more
information about COW filesystems.

The following options are supported by *lclean*:

*-d* _DIRECTORY_
	Assume the Netkit lab that is located inside _DIRECTORY_. If no *-d*
	option is provided, *lclean* assumes that the lab is located in the
	current directory. The path to the lab directory (being that the
	current directory or one provided by *-d*) must never contain spaces.

	This piece of information is necessary in order to remove some of the
	temporary files and to retrieve the list of the virtual machines that
	make up the lab.

The following standard options are also supported.

*-h*, *--help*
	Show usage information.

*-v*, *--verbose*
	Show which files are being deleted.

*\--version*
	Print information about the installed Netkit release and the host
	kernel version and exit. If \`\`_<unavailable>_\'\' is printed
	instead of a version number, then the corresponding information
	could not be retrieved (for example because a non-standard Netkit
	kernel or filesystem is being used).

# ENVIRONMENT VARIABLES

All Netkit commands require that the *NETKIT\_HOME* variable contains
the name of the directory Netkit is installed in.

Apart from this, *lclean* supports no other environment variables.

# NOTES

Despite the fact that the two command names sound similar, *lclean* has
nothing to do with *vclean*(1). While *lclean* is a tool to get rid of
temporary files inside a Netkit lab directory (i.e., it works on the
host filesystem), *vclean*(1) is the Netkit \`\`panic button\'\',
which allows to kill hanging processes and to restore settings that may
have been altered by Netkit during past executions (firewall settings,
configurations set up for tap interfaces, etc.).

# SEE ALSO

*lstart*(1), *lcrash*(1), *lhalt*(1), *lrestart*(1), *linfo*(1),
*ltest*(1), *vclean*(1), Netkit filesystem README.

# AUTHOR

*lclean* script: Stefano Pettini, Fabio Ricci, Massimo Rimondini\
This man page: Fabio Ricci, Massimo Rimondini
