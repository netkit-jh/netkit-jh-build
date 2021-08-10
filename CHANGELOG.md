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

# Removed
Remove 'machines' lab.conf variable