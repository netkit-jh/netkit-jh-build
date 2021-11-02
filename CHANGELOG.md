# Added
- `coreutils` as a required package to run Netkit (for `md5sum` and `stdbuf`)
- `uml_switch` logging now works
- `ltest` automated lab testing now works (added /etc/netkit/netkit-test-phase)
- `--mount` option to `vstart` - mount any host folder inside a machine
- Ability to use a _test/shared.test script to run the same script for all hosts with `ltest`. Script output is stored in _test/results/$hostname.shared
- `--delay` option to `ltest` to specify how long to wait for the lab to settle before running test scripts
- `--clean-directories` option to `vclean` to wipe `$HOME`/.netkit/, `$MCONSOLE_DIR`/, and `$HUB_SOCKET_DIR`/ (now included in `--clean-all`)
- `-f`|`--force` option to `vclean` for usage alongside `-H`|`--remove-hubs` to remove hubs even if they are being used by running machines
- `-v`|`--verbose` option to `lcrash`, `vclean`, `vconf`, `vcrash`, and `vdump`
- `--show-boot-log` option to `vstart` to display the boot log (replaced the `-v`|`--verbose` option, see [Modified](#modified))
- Support for whitespace (and some other special characters) in arguments
- Support for whitespace in the lab directory path
- ShellCheck directives for effective linting
- .gitignore now ignores compilation, test, and development artefacts
- Copyright notices for the Netkit-JH development team (alongside the original Netkit and Netkit-NG notices)

# Modified
- Machine names must conform to the Debian standard (which conforms to the RFC standard too)
- Better output when multiple labs are specified in `linfo -m`
- Script order:
    1. `/usr/bin/env bash` shebang
    2. Copyright notice
    3. Script description
    4. `usage_line` & `usage`
    5. Other function definitions in order of usage
    6. `SCRIPTNAME` set, `NETKIT_HOME` check, and `script_utils` and/or `lcommon` source
    7. `getopt` argument parsing
    8. Remainder of script
- `vcommand` usage signature is now `vcommand [OPTION]... MACHINE [COMMAND]`
- `vconnect` usage signature is now `vconnect [OPTION]... MACHINE`
- `machines` lab.conf variable is now `LAB_MACHINES`
- `LAB_MACHINES` does not strip whitespace. Names are comma-delimited
- tmux sessions are now named `netkit-vhost` (orig. `netkit-vm`)
- Tap interfaces are named `netkit_$user_md5`, where `user_md5` is an 8-character (truncated) MD5 digest of the owner's username for uniqueness
- Virtual network hub sockets are named with the user's MD5 digest instead of their name to avoid issues with invalid characters
- Rename `--kill` to `--just-kill` in `vcrash` and `lcrash`
- /etc/vhostconfigured (file indicating machine has been booted before) is now at /etc/netkit/.vhostconfigured
- `-p`|`--print` option has been changed to `-n`|`--dry-run`|`--just-print`|`--recon` for `vconf`, `vpackage`, and `vstart`. This follows what the Make utility uses
- `hostname` parameter in `kernel_cmd` (replaced `name` and `title`)
- `ltest` user defined scripts should be stored in _test/scripts/
- `ltest` script results are placed in _test/results/
- `--clean-all` in `vclean` now removes all items inside Netkit directories (`$HOME`/.netkit/, `$MCONSOLE_DIR`/, and `$HUB_SOCKET_DIR`/)
- `--clean-all` in `vclean` now affects machines owned by all users
- `vconf` manual entry is called `vconf` now (used to be `vconfig`)
- `-v`|`--verbose` in `vstart` now only displays machine information and ran commands. Boot log verbosity is now controlled with `--show-boot-log`, see [Added](#added)

# Removed
- `ltest` signature comparison, and the `-R`|`--rebuild-signature` and `--verify` options
- `-S`|`--script-mode` option from `ltest`
- `--machine` and `--command` switches in `vcommand` (see [Modified](#modified))
- `--machine` switch in `vconnect` (see [Modified](#modified))
- `USE_SUDO` configuration directive (default is to use `sudo` now, `su -c` has been removed)
- `--quiet` option for `lcrash`, `lhalt`, `vclean`, `vcrash`, and `vhalt` (`-q`|`--quick` still exists)
- `-q`|`--quiet` option from `vconf` and `vstart`
- Port helper compatibility
- `-w`|`--hostwd` option from `vstart` (it did not provide any purpose)
- /etc/netkit/netkit-welcome script (was disabled anyway)
- `name` and `title` parameters in `kernel_cmd` (see [Modified](#modified))
