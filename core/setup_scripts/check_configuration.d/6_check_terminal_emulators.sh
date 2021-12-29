#!/usr/bin/env bash

#     Copyright 2020-2021 Billy Bromell, Adam Bromiley, Mohammed Habib, Joshua
#     Hawking - Warwick Manufacturing Group, University of Warwick.
#     Copyright 2004-2007 Massimo Rimondini
#     Computer Networks Research Group, Roma Tre University.
#
#     This file is part of Netkit.
# 
#     Netkit is free software: you can redistribute it and/or modify
#     it under the terms of the GNU General Public License as published by
#     the Free Software Foundation, either version 3 of the License, or
#     (at your option) any later version.
# 
#     Netkit is distributed in the hope that it will be useful,
#     but WITHOUT ANY WARRANTY; without even the implied warranty of
#     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#     GNU General Public License for more details.
# 
#     You should have received a copy of the GNU General Public License
#     along with Netkit.  If not, see <http://www.gnu.org/licenses/>.

# This script is part of the Netkit configuration checker. It checks for
# available terminal emulators.


echo ">  Checking availability of terminal emulator applications:"


terminal_emulators=(
   "alacritty"
   "gnome-terminal"
   "kitty"
   "konsole"
   "tmux"
   "wsl.exe"
   "wt.exe"
   "xterm"
)

for term_executable in "${terminal_emulators[@]}"; do
   printf "%14s: " "$term_executable"
   
   if command -v -- "$term_executable" > /dev/null 2>&1; then
      echo "found"
      ok=1
   else
      echo "not found"
      [ "$term_executable" = "xterm" ] && xterm_warning=1
   fi
done

if [ -z "$ok" ]; then
   cat << END_OF_DIALOG

*** Warning: None of the supported terminal emulators appear to be installed on
             your system, meaning Netkit virtual machines cannot run in
             separate windows. Install terminal emulator(s) manually or with:
                "\$NETKIT_HOME/setup_scripts/change_terminal.sh"

             Netkit can still be used with the console options that are not
             'xterm' or 'tmux'.
END_OF_DIALOG
   exit 1
fi

if [ -n "$xterm_warning" ]; then
   cat << END_OF_DIALOG

*** Warning: xterm could not be detected on your system. Since xterm is the
             default terminal emulator used by Netkit virtual machines, it is
             recommended to have installed unless TERM_TYPE in netkit.conf has
             been suitably configured to use a different emulator. Install
             xterm manually or with:
                "\$NETKIT_HOME/setup_scripts/change_terminal.sh"
END_OF_DIALOG
   exit 1
fi


exit 0
