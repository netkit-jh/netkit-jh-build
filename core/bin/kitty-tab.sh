#!/usr/bin/env bash

#     Copyright 2022 Joseph Bunce - Warwick Manufacturing Group, University of
#     Warwick.
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

# Locking: http://mywiki.wooledge.org/BashFAQ/045

if [ ! -S /tmp/nk_kitty ]; then
   if mkdir /tmp/nk_kitty_lock 2> /dev/null; then
      trap "rm --force --recursive /tmp/nk_kitty_lock" 0

      kitty \
         --override allow_remote_control=yes \
         --detach \
         --listen-on unix:/tmp/nk_kitty \
         -- "$@"

      while [ ! -S /tmp/nk_kitty ]; do
         sleep 1
      done

      exit 0
   else
      while [ ! -S /tmp/nk_kitty ]; do
         sleep 1
      done
   fi
fi
    
kitty \
   @ \
   --to unix:/tmp/nk_kitty \
   launch \
   --type tab \
   -- "$@" \
   > /dev/null
