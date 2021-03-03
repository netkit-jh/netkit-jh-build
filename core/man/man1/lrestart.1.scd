lstart(1)

# NAME

lstart - start a netkit lab

# SYNOPSIS

*lstart* \[options\] \[_MACHINE-NAME_\...\]

*lrestart* \[options\] \[_MACHINE-NAME_\...\]

# DESCRIPTION

In order to ease setting up complex network experiences with Netkit it
is possible to completely describe them into special configuration
files, so that the experience can later be started with a single command
as if it were a virtual network \`\`laboratory\'\'.

The _lstart_ command can be used to achieve this purpose. In particular,
it starts a set of virtual machines that are part of a Netkit lab and
configures them according to the parameters contained in the lab
description. There is no difference between _lstart_ and _lrestart_. The
latter is just provided for backward compatibility.\
By default, all the virtual machines that make up the lab are started.
If a list of _MACHINE-NAME_s is provided, then only virtual machines
with a matching name _and_ that are part of the lab are started.

The configuration of a Netkit lab consists of some files and directories
whose names, locations and contents are described in the page
*lab.conf*(5).

The following options are supported by _lstart_:

*-d* _DIRECTORY_
	Start the Netkit lab that is located inside _DIRECTORY_. If no
	*-d* option is provided, _lstart_ assumes that the lab is located
	in the current directory. The path to the lab directory (being that
	the current directory or one provided by *-d*) must never contain
	spaces.

	Note that, in order to avoid starting undesired virtual machines,
	_lstart_ checks whether the current directory (or the directory
	specified with *-d*) contains at least a \`\`lab.conf\'\' or a
	\`\`lab.dep\'\' file, and refuses to start the lab if none of these file
	exists. See option *-F* below for disabling this behavior.

*-F*, *--force-lab*
	As a native behaviour, Netkit starts a virtual machine for each
	directory that it finds in a designed path, by default the current
	directory. In order to prevent the user from accidentally starting
	random virtual machines from a directory that does not contain a
	lab, lstart requires the presence of at least a \`\`lab.conf\'\' or
	a \`\`lab.dep\'\' file in the affected directory. If these files are
	not required for your setting, and you still want to launch your lab
	without creating either one, you can use option *-F* or *--force-lab*
	to convince Netkit that a certain directory is indeed a lab.

*-f*, *--fast*
	_lstart_ always waits for a virtual machine to complete its boot
	phase before launching the next one. This option disables this
	behaviour, and allows to launch several virtual machines at once.\
	This option has no effect if parallel startup is being used and is
	not impacted by the *-p* option.

*--tmux-attached*
	Run each VM in a tmux session and start a terminal attached to this
	tmux session. This is the same as setting USE\_TMUX=TRUE and
	TMUX\_OPEN\_TERMS=TRUE in netkit.conf

*--tmux-detached*
	Run each VM in a tmux session without opening any terminals. This is
	the same as setting USE\_TMUX=TRUE and TMUX\_OPEN\_TERMS=FALSE in
	netkit.conf

*-l*, *--list*
	Show a list of currently running virtual machines after the lab has
	been started up. This is useful to check whether all the hosts are
	up and running. Notice that, when the *-f* (or *--fast*) option
	is being used, _lstart_ does not wait for all the virtual machines
	of the lab to start up before printing this list, resulting in a
	possibly incomplete report. Hence, it is advised not to use *-l*
	(or *--list*) together with *-f* (or *--fast*).

*-o* _OPTION_, *--pass=*_OPTION_
	_lstart_ acts as a frontend to *vstart* (see *vstart*(1)). This
	option allows to pass an _OPTION_ unaltered to every invocation of
	*vstart*. This means that all the virtual machines of the lab will
	be launched with option _OPTION_. _OPTION_ should be specified
	exactly as it would be on the *vstart* command line, but always
	make sure that space characters are quoted (e.g., \`-fdummy.disk\'
	or \`--append=debug\' are ok, \`-M 32\' should be written as either
	\`-M32\' or \`\"-M 32\"\').

*-p*\[_VALUE_\]**
	Parallel startup is a special startup mode that allows to
	simultaneously boot several virtual machines. It is automatically
	enabled whenever a \`lab.dep\' file is found to exist inside the lab
	directory. This option forces parallel startup, even if the
	\`lab.dep\' file does not exist. In order to limit the load on your
	host, this option also allows to set a maximum number of virtual
	machines that at any time instant can be simultaneously booting.
	_VALUE_ must be a positive integer. A _VALUE_ of 0 corresponds to
	setting no limit. If no VALUE is provided, the default configured
	inside _netkit.conf_ is assumed (see *netkit.conf*(5)).\
	This option conflicts with *-s* (or *--sequential*).

	This option overrides the default value of MAX\_SIMULTANEOUS\_VMS inside
	_netkit.conf_ (see *netkit.conf*(5)).

	*Notice*: parallel startup requires that the *make* utility is
	properly installed on your system.

*-s*, *--sequential*
	Disable parallel startup, even if a \`lab.dep\' file is found to
	exist in the lab directory. This option is useful when you just want
	to launch specific virtual machines. In fact, if you just provide
	their _MACHINE-NAME_s on the command line, _lstart_ would still
	attempt to satisfy the dependencies, and this may result in starting
	other undesired virtual machines.\
	This option cannot be used together with *-p*.

*-w* _SECONDS_, *--wait=*_SECONDS_
	Wait for the specified amount of time before launching the next
	virtual machine. This option is always enforced, but it just becomes
	handy (for example, to reduce the load on the host machine) when
	using either *-f* (or *--fast*) or parallel startup.

	This option overrides the default value of GRACE\_TIME inside
	_netkit.conf_ (see *netkit.conf*(5)).

The following standard options are also supported.

*-h*, *--help*
	Show usage information.

*-v*, *--verbose*
	Show details about virtual machines while starting them.

*--version*
	Print information about the installed Netkit release and the host
	kernel version and exit. If \`\`_\<unavailable\>_\'\' is printed
	instead of a version number, then the corresponding information
	could not be retrieved (for example because a non-standard Netkit
	kernel or filesystem is being used).

# FILES

Apart from the lab configuration files, running a lab requires creating
some temporary files inside the current directory (i.e., the one the
_lstart_ command is executed from) as well as inside the lab directory.
Such files are:

_./machine_.ready
	These files are created by _lstart_ and are used to synchronize
	virtual machines when they are started. These files are
	automatically deleted when all the machines in the lab have properly
	started up. Yet, sometimes (e.g., when a virtual machine crashes in
	the boot phase) there may be \`.ready\' files left in the current
	directory even after the lab has been stopped. In this case you have
	to launch *lclean* (see *lclean*(1)) to get rid of them before
	the lab can be restarted.

_./machine_.disk
	This is the COW filesystem for virtual machine _machine_. These
	files are automatically removed when the lab is crashed with
	*lcrash* (see *lcrash*(1)), so that virtual machines can revert
	to their original state when the lab is restarted. If you want to
	preserve .disk files, use the *-F* (or *--keep-fs*) option of
	*lcrash*. On the other hand, *lhalt*(1) (see *lhalt*(1)) never
	removes .disk files, unless explicitly told to do it (with the
	*-r* or *--remove-fs* option).

	See the README in the Netkit filesystem package for more information
	about COW filesystems.

_lab-path_/readyfor.test
	This file is automatically created by *ltest* (see *ltest*(1)).
	It is used to ensure that the status of running virtual machines is
	only retrieved when they have all completed their boot phase.

# NOTES

_lstart_ is essentially a wrapper for *vstart*. Hence, if something
goes wrong, try to investigate the parameters used in the invocation of
*vstart* (they are reported in the _lstart_ output) and read the
*vstart*(1) documentation.

# SEE ALSO

_lab.conf_(5), _lclean_(1), _lhalt_(1), _lcrash_(1), _linfo_(1),
_ltest_(1), _make_(1), _vstart_(1), _netkit.conf_(5), Netkit filesystem
README.

# AUTHOR

_lstart_ script: Stefano Pettini, Fabio Ricci, Massimo Rimondini\
This man page: Fabio Ricci, Massimo Rimondini
