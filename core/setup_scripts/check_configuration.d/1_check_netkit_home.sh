#!/usr/bin/env bash

#     Copyright 2021 Adam Bromiley, Joshua Hawking - Warwick Manufacturing
#     Group, University of Warwick.
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

# This script is part of the Netkit configuration checker. It verifies that the
# NETKIT_HOME environment variable is set to a valid Netkit install directory.


echo -n ">  Checking Netkit home... "


# Check for existence of the NETKIT_HOME environment variable
if [ -z "$NETKIT_HOME" ]; then
   script_dir=$(dirname "$(readlink --canonicalize "$0")")
   install_dir=$(dirname "$(dirname "$script_dir")")

   cat << END_OF_DIALOG
failed.
*** Error: The environment variable NETKIT_HOME is not set. Assuming a standard
           install environment, the Netkit installation directory should be:
              $install_dir

           This should be set in your .bashrc file with:
              export NETKIT_HOME="$install_dir"

           Ensure that a new shell session is used, the current one has been
           reset, or .bashrc has been sourced before rerunning this script.
END_OF_DIALOG
   exit 255
fi


# Directories critical to Netkit's operation
netkit_dirs=(
   "$NETKIT_HOME/bin/"
   "$NETKIT_HOME/fs/"
   "$NETKIT_HOME/kernel/"
)

# Check for critical Netkit directories. If they are not present, we assume
# NETKIT_HOME is not the install directory.
for dir in "${netkit_dirs[@]}"; do
   if [ ! -d "$dir" ]; then
      cat << END_OF_DIALOG
failed.
*** Error: Critical directory '$dir' does not exist. Ensure NETKIT_HOME
           points to Netkit's installation directory; if it does, consider
           reinstallation.
END_OF_DIALOG
      exit 255
   fi
done


echo "passed."
exit 0
