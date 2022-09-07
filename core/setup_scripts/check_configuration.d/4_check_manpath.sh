#!/usr/bin/env bash

#     Copyright 2021-2022 Adam Bromiley - Warwick Manufacturing Group,
#     University of Warwick.
#     Copyright 2004-2007 Massimo Rimondini - Computer Networks Research Group,
#     Roma Tre University.
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

# This script is part of the Netkit configuration checker. It verifies that
# Netkit man pages are searchable via the MANPATH environment variable.


echo -n ">  Checking for availability of man pages... "


# MANPATH could alternatively be matched to the Netkit man page directory with
# a regular expression, however this would be messy with the allowance of
# trailing and back-to-back forward slashes, and more importantly symbolic
# links. This means the test depends on the man/ directory having netkit-jh.7.
if ! [ "$(man --where 7 netkit-jh)" -ef "$NETKIT_HOME/man/man7/netkit-jh.7" ]; then
   new_manpath="${MANPATH:+"\$MANPATH:"}:$NETKIT_HOME/man/"

   cat << END_OF_DIALOG
failed.
*** Warning: The MANPATH environment variable is not properly set. This will
             make Netkit man pages inaccessible. You should set it to the
             following value (all colons must be included):
                $new_manpath

             This should be set in your .bashrc file with:
                export MANPATH="$new_manpath"
END_OF_DIALOG
   exit 1
fi


echo "passed."
exit 0
