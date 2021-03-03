ltest(1)

# NAME

ltest - test a netkit lab

# SYNOPSIS

*ltest* \[options\] \[_MACHINE-NAME_\...\]

# DESCRIPTION

_ltest_ is a tool for retrieving and saving information about the state
of running virtual machines inside a Netkit lab. These information can
then be distributed with the lab itself, so that users can easily test
whether the lab still behaves in the expected way when it is being
launched on a different machine or Netkit distribution.

Basically, _ltest_ takes care of launching the lab in a \`test mode\',
running an ad-hoc set of scripts on virtual machines, and storing their
output on the host filesystem. If the test is being run for the first
time, _ltest_ creates a \`\`signature\'\' of the test results that is
used as a fingerprint of a correctly behaving lab. The next times that
the test is run, test results are compared with the signature to check
that the lab still behaves as expected. After running the test, the lab
is then automatically stopped, any temporary files are deleted and the
outcome of the test is printed as output.

In the following, it is assumed that _lab-path_ is the directory in
which the lab is located.

Whenever a test is run, a subdirectory \`\_test\' is created inside
_lab-path_ (if it does not already exist) and the results of the test
are stored inside it. Any existing results of previous tests are
overwritten. Subdirectory \`\_test/signature\' and \`\_test/results\'
will contain the signature of the lab test and the outcome of the last
executed test, respectively.

Providing a list of *MACHINE-NAME*s on the command line has the effect
of limiting the scope of the test to these virtual machines (comparing
two tests performed on different sets of virtual machines obviously
leads to a negative outcome).

_ltest_ supports the same options as _lstart_(1), except *-f*, and
some additional options described below.

*NOTE*: Unless differently specified (e.g., by using the *--pass*
option or environment variables), _ltest_ runs virtual machines without
an attached terminal. Therefore, no window will pop up and no output
will be shown by virtual machines during a test. This has been chosen in
order to ease the automation of regression tests.

# OPTIONS

Besides the options supported by *lstart*, *ltest* also support the
following options:

*-R*, *--rebuild-signature*
	Force generating a new signature for the lab, even if one already
	exists. Overwrites any existing signature.

*-S*, *--script-mode*
	Use a more concise output with pretty printing of the test outcome,
	which is more suitable for testing a large number of labs from a
	script.

*--verify=*_TESTTYPE_
	After a signature has been generated, the outcome of any following
	tests is compared with information in the signature. By default, for
	each virtual machine _ltest_ verifies the outcome of the
	user-defined test if one is available in the signature, or of the
	built-in test otherwise. Option *--verify* allows to force
	_ltest_ to always verify only a certain kind of test. Possible
	values for _TESTTYPE_ are as follows:

	*user*
		Consider only user-defined test scripts.
	*builtin*
		Consider only predefined built-in tests.
	*both*
		Consider both kinds of test scripts (i.e., takes into account the built-in test even when a user-defined test exists for a certain virtual machine).

Verifications are always performed only for those tests that exist in
the signature, regardless of whether or not option *--verify* is
being used.

# HOW TO PERFORM A TEST

A Netkit test consists of two kinds of scripts: *default* (built-in)
and *user*.

- The *default* script is built-in into the _ltest_ support scripts and cannot be changed by the user. It runs some commands inside the virtual machine in order to store the state of its network interfaces, routing table, listening TCP and UDP ports, and running processes.

The output of the *default* script is saved into
\`_lab-path_/\_test/results/_machine_.default\',
where _machine_ is the name of the virtual machine the test has been
performed on. The file format for the output of the default test is
quite simple. There are several sections which are started by a textual
description between square brackets. The contents of each section are
the output of a specific command. The following list describes both the
sections and the corresponding commands:

*\[NETWORK INTERFACES\]*
	(essentially) the output of \`ip addr show\'.

*\[ROUTING TABLE\]*
	(essentially) the output of \`route -n\'.

*\[LISTENING PORTS\]*
	(essentially) the output of \`netstat -tuwln\'.

*\[PROCESSES\]*
	(essentially) the output of \`ps -e -o uid,command\'.

- The *user* script may be used to customize the test procedure. In particular, it can be used to dump information that are defined by a user through a personal script.

_ltest_ reads the user test script for machine _machine_ from
\`_lab-path_/\_test/_machine_.test\' and writes the output to 
\`_lab-path_/\_test/results/_machine_.user\'. Remember that the user test 
script must be marked as executable. You can achieve this by using the 
following command:

	chmod +x _lab-path_/\_test/_machine_.test

*Notice*: every time you launch _ltest_ any existing output of
previous tests is overwritten. Hence, remember to move output files
elsewhere before performing other instances of the test.

# RETURN VALUE

_ltest_ has a zero return value if and only if the test completed
successfully or a new signature has been generated. This allows, for
example, to automate lab tests by using a command like the following:

```
if ! ltest -d my_lab --script-mode; then
   echo "Lab test failed!" > lab.log
fi
```

# FILES

## Test scripts

_lab-path_/\_test/_machine_.test
	This is an executable script created by the user. Actually, it can
	be any kind of executable file (i.e., binary files are allowed as
	well) and, in case it is a script, it can be written in any
	scripting language whose interpreter is installed inside virtual
	machines.

The only requirement is that it must be an executable file. To achieve
this, you can use the following command:

```
chmod +x lab-path/_test/machine.test
```

## Test output files

The output of the test scripts is stored inside the following files:

_lab-path_/\_test/results/_machine_.default
	This file contains the output of the execution of the default test
	operations.

_lab-path_/\_test/results/_machine_.user
	This file contains the output of the execution of
	_lab-path_/\_test/_machine_.test.

## Test signature files

The first time a test is being run on a lab, _ltest_ creates a
\`\`signature\'\' instead of the test results. The signature is used by
subsequent tests as a fingerprint of a correctly running lab. Signature
files are exactly the same as result files, and are placed at the
following locations:

- _lab-path_/\_test/signature/_machine_.user
- _lab-path_/\_test/results/_machine_.default

## Other files

_/etc/init.d/netkit-test-phase (inside virtual machines)_
	This file is the container for the default test script. It resides
	in the virtual machines filesystem. In case you want to alter the
	default test operations, this is the file you must work on.

	*Notice*: remember to launch a virtual machine by using the *-W*
	option of *vstart* (see *vstart*(1)) in order to make the changes to
	_netkit-test-phase_ permanent. Please read carefully the man page of
	*vstart*(1) and the README in the Netkit filesystem package before
	changing the Netkit filesystem.

# EXAMPLES

The following one is an example of a test file \`pc1.default\' that has
been generated by the default testing script:

```
[INTERFACES]

lo        Link encap:Local Loopback
          inet addr:127.0.0.1  Mask:255.0.0.0
          inet6 addr: ::1/128 Scope:Host
          UP LOOPBACK RUNNING  MTU:16436  Metric:1


[ROUTE]

Kernel IP routing table
Destination     Gateway         Genmask         Flags   MSS Window  irtt Iface

[LISTENING PORTS]

Active Internet connections (servers and established)
Proto Recv-Q Send-Q Local Address           Foreign Address         State

[PROCESSES]

  UID COMMAND
	0 init [2]
	0 [ksoftirqd/0]
	0 [events/0]
	0 [khelper]
	0 [kthread]
	0 [kblockd/0]
	0 [pdflush]
	0 [pdflush]
	0 [aio/0]
	0 [kswapd0]
	0 /bin/sh /etc/init.d/rc 2
	0 /sbin/klogd
	0 /sbin/syslogd
	0 /bin/bash /etc/rc2.d/S99netkit-phase2 start
	0 /bin/bash /etc/init.d/netkit-test-phase
	0 /bin/ps -e -o uid,command
```

In order to write a customized test script you can proceed as follows.
Assume your lab is located inside directory \`/home/foo/lab\',
and that it consists of machines *pc1* and *pc2*. The first step to
customize the test is to create a subdirectory \`/home/foo/lab/\_test\'.
Once done, you can create your own test script \`/home/foo/lab/\_test/pc1.test\'
for machine *pc1*. For example, the following script can be used to
dump the current system time of the virtual machine by using python:

```
#!/usr/bin/python
import time
print time.asctime(time.localtime(time.time()));
```

It is now possible to launch the lab in test mode by using \`ltest
/home/foo/lab\'. This will execute the default test operations (i.e.,
dump of network interfaces, routing table, etc.) on both *pc1* and
*pc2* and the customized script on *pc1* only. The results of the
tests will be saved into \`/home/foo/lab/\_test/results\',
and will consist of files \`pc1.default\', \`pc1.user\', and
\`pc2.default\'. In particular, \`pc1.user\' should look as follows:

```
Thu Jul 21 18:31:25 2005
```

# NOTES

The typical usage of this script is for regression tests of Netkit labs
over different version of Netkit and for testing that Netkit labs work
properly on different host configurations.

# SEE ALSO

_lstart_(1), _lclean_(1), _lcrash_(1), _lrestart_(1), _linfo_(1),
_lhalt_(1).

# AUTHOR

ltest script: Fabio Ricci, Stefano Pettini, Massimo Rimondini\
This man page: Fabio Ricci, Massimo Rimondini
