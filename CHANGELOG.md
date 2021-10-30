# Added
- `coreutils` as a required package to run Netkit (for `md5sum` and `stdbuf`)
- `uml_switch` logging now works
- `ltest` automated lab testing now works (added /etc/netkit/netkit-test-phase)

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

# Removed
- `ltest` signature comparison, and the `-R`|`--rebuild-signature` and `--verify` options
- `-S`|` --script-mode` option from `ltest`
- `--machine` and `--command` switches in `vcommand` (see [Modified](#modified))
- `--machine` switch in `vconnect` (see [Modified](#modified))
- `USE_SUDO` configuration directive (default is to use `sudo` now, `su -c` has been removed)
- `--quiet` option for `lcrash`, `lhalt`, `vclean`, `vcrash`, and `vhalt` (`-q`|`--quick` still exists)
- `-q`|`--quiet` option from `vconf` and `vstart`
- Port helper compatibility
- `-w`|`--hostwd` option from `vstart` (it did not provide any purpose)
- /etc/netkit/netkit-welcome script (was disabled anyway)
- `name` and `title` parameters in `kernel_cmd` (see [Modified](#modified))
