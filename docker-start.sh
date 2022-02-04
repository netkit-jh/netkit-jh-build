#!/usr/bin/env bash

#     Copyright 2020-2022 Billy Bromell, Adam Bromiley - Warwick Manufacturing
#     Group, University of Warwick.
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

# Download and install Netkit-JH in the user's home directory.


# ANSI color escape sequences
color_normal=$'\033[0m'
color_red=$'\033[0;31m'
color_green=$'\033[0;32m'
color_magenta=$'\033[0;35m'


# Link to tutorial
tutorial_link="https://netkit-jh.github.io/docs/dev/guides/dockerbuild/"


if [ -n "$(mount --show-labels --types proc)" ]; then
   echo "/proc already mounted ${color_green}[✓]$color_normal"
elif ! mount --types proc proc /proc; then
   echo "${color_red}Could not mount /proc$color_normal"
   exit 1
fi

if mount | grep '/netkit-build' &> /dev/null; then
   echo "/netkit-build mounted ${color_green}[✓]$color_normal"
else
   cat << END_OF_DIALOG
${color_red}Source Code Dir not mounted.$color_normal
Remember to pass a volume in the docker argument with:
   -v PATH_TO_NETKIT_JH_BUILD:/netkit-build

$color_magenta$tutorial_link$color_normal
END_OF_DIALOG
   exit 1
fi

# Should already be in /netkit-build from WORKDIR in Dockerfile
if [ -f "Makefile" ]; then
   echo "Building Netkit${MAKE_ARGS:+" with '$MAKE_ARGS' as arguments to the Makefile"}"

   # shellcheck disable=SC2086
   if make $MAKE_ARGS; then
      echo "Make exited successfully${color_green}[✓]$color_normal"
   else
      echo "${color_red}Error running Make$color_normal"
      exit 1
   fi
else
   cat << END_OF_DIALOG
${color_red}Makefile doesn't exist.$color_normal
Have you cloned the netkit-jh-build source? Ensure you are passing the correct
directory as a Docker volume. You may need to give a full path.

$color_magenta$tutorial_link$color_normal
END_OF_DIALOG
   exit 1
fi
