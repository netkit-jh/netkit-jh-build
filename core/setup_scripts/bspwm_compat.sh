#!/usr/bin/env bash

#     Copyright 2021 Adam Bromiley, Max Barstow, Joshua Hawking - Warwick
#     Manufacturing Group, University of Warwick.
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


pidof bspwm
if [ $? -eq 0 ] ; then
    echo "Bspwm is running! Downloading and applying patch."
    wget -O ${NETKIT_HOME}/bin/bspwm.patch --show-progress "https://raw.githubusercontent.com/netkit-jh/netkit-jh-build/master/patches/bspwm.patch"
    wget -O ${NETKIT_HOME}/bin/szhelper.rb --show-progress "https://raw.githubusercontent.com/netkit-jh/netkit-jh-build/master/scripts/szhelper.rb"
    chmod +x ${NETKIT_HOME}/bin/szhelper.rb
    patch -ruN -d ${NETKIT_HOME}/bin -i bspwm.patch
    rm ${NETKIT_HOME}/bspwm.patch
fi
