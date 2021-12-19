# User Experience Changelog
## Added
- `--mount` option to `vstart` - mount any host folder inside a machine
- Ability to use a _test/shared.test script to run the same script for all hosts with `ltest`. Script output is stored in _test/results/$hostname.shared
- Multiple taps can be created for machines to have their own unique interfaces (they can still share if the same collision domain is used)
- Support for whitespace (and some other special characters) in arguments
- Support for whitespace in the lab directory path
- `--clean-directories` option to `vclean` to wipe `$HOME`/.netkit/, `$MCONSOLE_DIR`/, and `$HUB_SOCKET_DIR`/ (now included in `--clean-all`)

### Other Added
- `-v`|`--verbose` option to `lcrash`, `vclean`, `vconf`, `vcrash`, and `vdump`
- `-f`|`--force` option to `vclean` for usage alongside `-H`|`--remove-hubs` to remove hubs even if they are being used by running machines
- `--delay` option to `ltest` to specify how long to wait for the lab to settle before running test scripts
- `--show-boot-log` option to `vstart` to display the boot log (replaced the `-v`|`--verbose` option, see [Other Modified](#other-modified))
- Ability to affect a specific user for `-T`|`--remove-tunnels` in `vclean`
- `coreutils` as a required package to run Netkit (for `sha256sum` and `stdbuf`)

## Modified
- Tap interfaces are specified with `DOMAIN,TAP-ADDRESS,GUEST-ADDRESS` (`DOMAIN` does not have to be `tap` now, it should be a regular collision domain name). See [Added](#added) for information on multiple tap interface specifications
- `vcommand` usage signature is now `vcommand [OPTION]... MACHINE [COMMAND]`
- `vconnect` usage signature is now `vconnect [OPTION]... MACHINE`
- `machines` lab.conf variable is now `LAB_MACHINES`
- `LAB_MACHINES` variable is comma-delimited (orig. whitespace-delimited)
- `ltest` user defined scripts should be stored in _test/scripts/
- `ltest` script results are placed in _test/results/

### Other Modified
- `vconf` manual entry is called `vconf` now (used to be `vconfig`)
- `-v`|`--verbose` in `vstart` now only displays machine information and ran commands. Boot log verbosity is now controlled with `--show-boot-log`, see [Other Added](#other-added)
- Rename `--kill` to `--just-kill` in `vcrash` and `lcrash`
- `-p`|`--print` option has been changed to `-n`|`--dry-run`|`--just-print`|`--recon` for `vconf`, `vpackage`, and `vstart`. This follows what the Make utility uses
- `--clean-all` in `vclean` now removes all items inside Netkit directories (`$HOME`/.netkit/, `$MCONSOLE_DIR`/, and `$HUB_SOCKET_DIR`/)
- `--clean-all` in `vclean` now affects machines owned by all users
- Machine names must conform to the Debian standard (which conforms to the RFC standard too)
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

### Other Removed
- Port helper compatibility
- `-w`|`--hostwd` option from `vstart` (it did not provide any purpose)
- `lrestart` symbolic link (pointed to `lstart` and provided no default or additional functionality)

# Development Changelog
## Added
- ShellCheck directives for effective linting
- .gitignore now ignores compilation, test, and development artefacts
- Copyright notices for the Netkit-JH development team (alongside the original Netkit and Netkit-NG notices)
- Collision domain argument to `manage_tuntap`

## Modifed
- All scripts are interpreted by Bash now
- Script order:
    1. `/usr/bin/env bash` shebang
    2. Copyright notice
    3. Script description
    4. `usage_line` & `usage`
    5. Other function definitions in order of usage
    6. `SCRIPTNAME` set, `NETKIT_HOME` check, and `script_utils` and/or `lcommon` source
    7. `getopt` argument parsing
    8. Non-option argument parsing
    9. Remainder of script
- `hostname` parameter in `kernel_cmd` (replaced `name` and `title`)

## Removed
- `name` and `title` parameters in `kernel_cmd`
- /etc/netkit/netkit-welcome script (was disabled anyway)

# Bug Fixes
- `uml_switch` logging now works
- `ltest` automated lab testing now works (added /etc/netkit/netkit-test-phase)
