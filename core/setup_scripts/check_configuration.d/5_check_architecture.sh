#!/usr/bin/env bash

#     Copyright 2021-2022 Adam Bromiley, Joshua Hawking, Alex McCoy - Warwick
#     Manufacturing Group, University of Warwick.
#     Copyright 2004-2010 Massimo Rimondini - Computer Networks Research Group,
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

# This script is part of the Netkit configuration checker. It checks if the
# user's GNU C Library version is new enough to support the Linux kernel used
# by Netkit.


echo -n ">  Checking GNU C Library version... "


# Read user-defined Netkit configuration override in order of file localisation
# (Netkit defaults, per system, per install, per user) to get the kernel binary
# location.
# shellcheck source=../../netkit.conf.default
[ -f "$NETKIT_HOME/netkit.conf.default" ] && . -- "$NETKIT_HOME/netkit.conf.default"
# shellcheck disable=SC1091
[ -f /etc/netkit.conf ] && . "/etc/netkit.conf"
# shellcheck source=../../netkit.conf
[ -f "$NETKIT_HOME/netkit.conf" ] && . -- "$NETKIT_HOME/netkit.conf"
# shellcheck disable=SC1091
[ -f "$HOME/.netkit/netkit.conf" ] && . -- "$HOME/.netkit/netkit.conf"


# Get minimum glibc version required by the kernel binary
required_glibc_version=$(
   objdump --dynamic-syms "$VM_KERNEL" |
   grep --extended-regexp --only-matching "GLIBC_[0-9.]+" |
   sed 's/GLIBC_//' |
   sort --version-sort |
   tail --lines 1
)

# Get current glibc version used by the system
current_glibc_version=$(ldd --version | awk 'NR==1 { print $NF }')

# Compare the two versions and get the lowest version number
oldest_glibc_version=$(
   printf "%s\n%s\n" "$current_glibc_version" "$required_glibc_version" |
   sort --version-sort |
   head --lines 1
)

if [  "$current_glibc_version" = "$oldest_glibc_version" ]; then
   # The required glibc version number is greater than what is installed on the
   # user's system
   cat << END_OF_DIALOG
failed.
*** Error: Your system cannot execute the Linux kernel used by Netkit because
           it requires a glibc version of $required_glibc_version or higher. Your system
           currently uses version $current_glibc_version.
END_OF_DIALOG
   exit 255
fi


echo "passed."
exit 0
