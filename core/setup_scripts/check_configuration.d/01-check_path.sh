#!/bin/false
# shellcheck shell=bash

#     Copyright 2021 Adam Bromiley - Warwick Manufacturing Group, University of
#     Warwick.
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

# This script is part of the Netkit configuration checker. Do not attempt to run
# it as a standalone script.

# This script should perform (and, optionally, output information about) a test
# to see if the host on which Netkit is run satisfies a specific requirement.
# The script is expected to always run till its end (i.e., there must be no exit
# instructions). If the host configuration does not comply to the requirement
# you should call one of the functions "check_warning" or "check_failure"
# (depending on the severity of the problem).

# Check if the path to the Netkit directory contains spaces

echo -n ">  Checking path correctness... "

if echo "$CHECK_NETKIT_HOME" | grep -q " "; then
   echo "failed!"
   echo
   echo "*** Error: Netkit appears to be installed inside a directory whose path"
   echo "contains spaces:"
   echo "\"$CHECK_NETKIT_HOME\""
   echo "Please move it to a different directory and try again."
   echo
   check_failure
else
   echo "passed."
fi
