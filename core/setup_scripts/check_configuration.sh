#!/usr/bin/env bash

#     Copyright 2021-2022 Adam Bromiley, Joshua Hawking - Warwick Manufacturing
#     Group, University of Warwick.
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

# This is the Netkit check_configuration.sh script. It performs several tests
# to verify that the user's system meets fundamental requirements.


# Force language to avoid localization errors
export LANG=C


SCRIPTNAME=$(basename -- "$0")

# Ensure NETKIT_HOME is set
if [ -z "$NETKIT_HOME" ]; then
   echo 1>&2 "$SCRIPTNAME: The NETKIT_HOME environment variable is not set"
   exit 1
fi


# ANSI color escape sequences
color_normal=$'\033[0m'
color_red=$'\033[31;1m'
color_green=$'\033[32;1m'
color_yellow=$'\033[33;1m'

warning_count=0

for script in "$NETKIT_HOME/setup_scripts/check_configuration.d/"*; do
   [ ! -e "$script" ] && continue

   "$script"
   return_value=$?

   case $return_value in
      255)
         cat << END_OF_DIALOG

${color_red}[ ERROR ]$color_normal Your system is not configured properly. Correct the above errors and
verify with $SCRIPTNAME before using Netkit.
END_OF_DIALOG
         exit 255
         ;;
      *)
         # On success, 0 is returned. If there are warnings (no errors), the
         # warning count is returned.
         (( warning_count += return_value ))
         ;;
   esac
done


if [ "$warning_count" -gt 0 ]; then
   cat << END_OF_DIALOG

${color_yellow}[WARNING]$color_normal It has been advised that $warning_count configuration setting(s) should be
          changed. You may also ignore this message, but doing so may limit
          available features, or result in Netkit not functioning correctly on
          your system.
END_OF_DIALOG
   exit "$warning_count"
fi


cat << END_OF_DIALOG
${color_green}[ READY ]$color_normal Congratulations! Your Netkit setup is now complete; enjoy Netkit!
END_OF_DIALOG
exit 0
