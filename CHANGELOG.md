# User Experience Changelog
## Added
- Command tab-completion (in Bash) including machine name and collision domain completion
- `--mount` option to `vstart` - mount any host folder inside a machine
- Ability to use a _test/shared.test script to run the same script for all hosts with `ltest`. Script output is stored in _test/results/`$hostname`.shared
- Multiple taps can be created for machines to have their own unique interfaces (they can still share if the same collision domain is used)
- Support for whitespace (and some other special characters) in arguments
- Support for whitespace in the lab directory path
- `--clean-directories` option to `vclean` to wipe `$HOME`/.netkit/ (ignoring netkit.conf), `$MCONSOLE_DIR`/, and `$HUB_SOCKET_DIR`/ (now included in `--clean-all`)

### Other Added
- `-v`|`--verbose` option to `lcrash`, `vclean`, `vconf`, `vcrash`, and `vdump`
- `-f`|`--force` option to `vclean` for usage alongside `-H`|`--remove-hubs` to remove hubs even if they are being used by running machines
- `--delay` option to `ltest` to specify how long to wait for the lab to settle before running test scripts
- `--show-boot-log` option to `vstart` to display the boot log (replaced the `-v`|`--verbose` option, see [Other Modified](#other-modified))
- `--version` option to install-netkit-jh.sh
- Ability to affect a specific user for `-T`|`--remove-tunnels` in `vclean`
- `bash`, `binutils`, `coreutils`, `iproute2`, `lsof`, and `util-linux` as dependencies

## Modified
- Netkit's default configuration is stored in netkit.conf.default. This should not be modified and can be overridden with netkit.conf
- Tap interfaces are specified with `DOMAIN,TAP-ADDR,GUEST-ADDR` (`DOMAIN` does not have to be `tap` now, it should be a regular collision domain name). See [Added](#added) for information on multiple tap interface specifications
- `vcommand` usage signature is now `vcommand [OPTION]... MACHINE [COMMAND]`
- `vconnect` usage signature is now `vconnect [OPTION]... MACHINE`
- `machines` lab.conf variable is now `LAB_MACHINES`
- Minimum Bash version (4.4) is enforced in the 1_check_shell.sh configuration check script
- `LAB_MACHINES` variable is comma-delimited (orig. whitespace-delimited)
- `ltest` user defined scripts should be stored in _test/scripts/
- `ltest` script results are placed in _test/results/
- 'tap' interfaces are created under a /24 subnet now (not /8). This allows more 'tap' interfaces on the host to occupy private address spaces

### Other Modified
- `vconf` manual entry is called `vconf` now (used to be `vconfig`)
- `-v`|`--verbose` in `vstart` now only displays machine information and ran commands. Boot log verbosity is now controlled with `--show-boot-log`, see [Other Added](#other-added)
- Rename `--kill` to `--just-kill` in `vcrash` and `lcrash`
- `-p`|`--print` option has been changed to `-n`|`--dry-run`|`--just-print`|`--recon` for `vconf`, `vpackage`, and `vstart`. This follows what the Make utility uses
- `--clean-all` in `vclean` now removes all items inside Netkit directories (`$HOME`/.netkit/, `$MCONSOLE_DIR`/, and `$HUB_SOCKET_DIR`/)
- `--clean-all` in `vclean` now affects machines owned by all users
- Machine names must conform to the Debian standard (which conforms to the RFC standard too). See `hostname_regex` in core/bin/script_utils for more guidance
- Collision domain names must conform to a regular expression and length-check. See `collision_domain_name_regex` in core/bin/script_utils for more guidance
- Better output when multiple labs are specified in `linfo -m`
- tmux sessions are now named `netkit-vhost` (orig. `netkit-vm`)
- Tap interfaces are named `nk_$interface_sha256`, where `interface_sha256` is an 12-character (truncated) SHA-256 digest of the collision domain name SHA-256 appended to the owner's username's SHA-256 for uniqueness and avoiding character set issues
- `iptables` forwarding rule uses the new interface specification to match the input interface (`nk_+`)
- Virtual network hub sockets are named with the username's and domain's SHA-256 digests instead of plaintext to avoid issues with invalid characters. Tap sockets are identfied in the filename
- /etc/vhostconfigured (file indicating machine has been booted before) is now at /etc/netkit/.vhostconfigured

## Removed
- `--machine` and `--command` switches in `vcommand` (see [Modified](#modified))
- `--machine` switch in `vconnect` (see [Modified](#modified))
- `ltest` signature comparison, and the `-R`|`--rebuild-signature` and `--verify` options
- `-S`|`--script-mode` option from `ltest`
- `USE_SUDO` configuration directive (default is to use `sudo` now, `su -c` has been removed)
- `--quiet` option for `lcrash`, `lhalt`, `vclean`, `vcrash`, and `vhalt` (`-q`|`--quick` still exists)
- `-q`|`--quiet` option from `vconf` and `vstart`
- `konsole-tab` argument to the `--xterm` option (and the ktabstart script)
- bspwm compatibility patch files. They fail with the radically changed target files and fix a general issue other users have identified but only for bspwm - it applies to tmux, Windows Terminal, and other terminal emulators and window managers
- Dependency on the `net-tools` (`ifconfig`) package for `manage_tuntap` in favour of `iproute2`

### Other Removed
- Port helper compatibility
- `-w`|`--hostwd` option from `vstart` (it did not provide any purpose)
- `lrestart` symbolic link (pointed to `lstart` and provided no default or additional functionality)
- `--fix` option from check_configuration.sh
- `MCONSOLE_DIR` environment variable detection from uml_mconsole
- Support for netkit.conf overriding with the `NETKIT_FILESYSTEM`, `NETKIT_MEMORY`, `NETKIT_KERNEL`, and `NETKIT_TERM` environment variables
- 01-check_path.sh setup script (whitespace in paths is safely handled now)
- 06-check_aux_tools.sh and 10-check_dumpers.sh setup scripts

# Development Changelog
## Added
- ShellCheck directives for effective linting
- .gitignore now ignores compilation, test, and development artefacts
- Copyright notices for the Netkit-JH development team (alongside the original Netkit and Netkit-NG notices)
- Collision domain argument to `manage_tuntap`
- vcommon source script to contain functions common to the vcommands (analogous to lcommon)

## Modifed
- All scripts are interpreted by Bash now (minimum required version 4.4, see [Modified](#modified))
- Script order:
    1. `/usr/bin/env bash` shebang
    2. Copyright notice
    3. Script description
    4. `usage_line` & `usage`
    5. Other function definitions in order of usage
    6. `script_utils` and (optional) `lcommon`/`vcommon` source
    7. `getopt` argument parsing
    8. Non-option argument parsing
    9. Remainder of script
- `hostname` parameter in `kernel_cmd` (replaced `name` and `title`)
- Renamed check_configuration.d/ scripts

## Removed
- `name` and `title` parameters in `kernel_cmd`
- /etc/netkit/netkit-welcome script (was disabled anyway)
- check.sh filesystem check script

# Bug Fixes
- `uml_switch` logging now works
- `ltest` automated lab testing now works (added /etc/netkit/netkit-test-phase)

# Known Issues
- The man pages have not been updated yet
- Removing an interface with `vconf` crashes the machine
- Whitespace in the `VM_MODEL_FS` (`-m`|`--model-fs`) and `VM_KERNEL` (`--kernel`) configuration variables, `HOME` environment variable, or the argument to `--mount`, `--hostlab`, and `--exec` may break when ran with Windows Terminal due to escaped quotes not being honoured by the extra layer of shell interpretation.
- A terminating quotation mark in the `VM_MODEL_FS` (`-m`|`--model-fs`) configuration variable will be removed by the `get_vhost_info_by_pid` function if the instance is running in Windows Terminal. This is significant in `vcrash`'s and `vhalt`'s `--remove-fs` option - the disk file will not be removed (and a file with the same name sans quote mark will be, if exists).
