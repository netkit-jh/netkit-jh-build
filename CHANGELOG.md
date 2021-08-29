# Added

# Modified
- Machine names must conform to the Debian standard (which conforms to the RFC standard too)
- Better output when multiple labs are specified in `linfo -m`
- Script order:
    1. /usr/bin/env bash shebang
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

# Removed
- `--machine` and `--command` switches in `vcommand` (see [Modified](#modified))
- `--machine` switch in `vconnect` (see [Modified](#modified))
