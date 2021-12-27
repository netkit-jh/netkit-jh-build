#!/usr/bin/env bash

#     Copyright 2021 Adam Bromiley, Mohammed Habib, Joshua Hawking - Warwick
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


SCRIPTNAME=$(basename -- "$0")

if [ -z "$NETKIT_HOME" ]; then
   echo 1>&2 "$SCRIPTNAME: The NETKIT_HOME environment variable is not set"
   exit 1
fi


if [ -f /etc/netkit.conf ]; then
   netkit_conf="/etc/netkit.conf"
elif [ -f "$NETKIT_HOME/netkit.conf" ]; then
   netkit_conf="$NETKIT_HOME/netkit.conf"
elif [ -f "$HOME/.netkit/netkit.conf" ]; then
   netkit_conf="$HOME/.netkit/netkit.conf"
else
   echo 1>&2 "$SCRIPTNAME: netkit.conf not found"
   exit 1
fi

# shellcheck source=../netkit.conf
. -- "$netkit_conf"


cat << END_OF_DIALOG
Current terminal emulator (TERM_TYPE): '$TERM_TYPE'
Which terminal emulator would you like to use for Netkit machines?

(1) xterm - reliable, stable but ancient UI (default installation)
(2) Alacritty - modern and GPU-accelerated terminal emulator
(3) kitty -  another modern and GPU-accelerated emulator
(4) GNOME Terminal - default terminal for Ubuntu
(5) wsl - provides WSL compatiblity through the Windows Console (conhost.exe)
(6) wt - WSL compatibility via Windows Terminal (recommended for WSL hosts)

NOTE: required repositories/packages will be installed. For WSL compatibility,
/etc/wsl.conf must be configured to append the host's PATH to the virtual
machine's PATH. Ensure Windows Terminal is already installed on the host if
selecting option (6).
END_OF_DIALOG


while true; do
   read -rp "Which terminal would you like to use [1-6]? " response
   case $response in
      1)
         if ! command -v -- "xterm" > /dev/null 2>&1; then
            sudo apt-get update
            sudo apt-get install xterm
         fi

         term_type="xterm"
         terminal="xterm"
         ;;
      2)
         if ! command -v -- "alacritty" > /dev/null 2>&1; then
            sudo add-apt-repository ppa:mmstick76/alacritty
            sudo apt-get update
            sudo apt-get install alacritty
         fi

         term_type="alacritty"
         terminal="Alacritty"
        ;;
      3)
         if ! command -v -- "kitty" > /dev/null 2>&1; then
            sudo apt-get update
            sudo apt-get install kitty
         fi

         term_type="kitty"
         terminal="kitty"
         ;;
      4)
         if ! command -v -- "gnome-terminal" > /dev/null 2>&1; then
            sudo apt-get update
            sudo apt-get install gnome-terminal
         fi

         term_type="gnome"
         terminal="GNOME Terminal"
         ;;
      5)
         if ! command -v -- "wsl.exe" > /dev/null 2>&1; then
            echo 1>&2
               "$SCRIPTNAME: wsl.exe: command not found. Is WSL configured to share environment variables with Windows?"
            exit 1
         fi

         term_type="wsl"
         terminal="Windows Console"
         ;;
      6)
         if ! command -v -- "wt.exe" > /dev/null 2>&1; then
            echo 1>&2
               "$SCRIPTNAME: wt.exe: command not found. Is WSL configured to share environment variables with Windows?"
            exit 1
         fi

         term_type="wt"
         terminal="Windows Terminal"
         ;;
   esac
done

# Change TERM_TYPE in netkit.conf
sed --in-place -- "s/TERM_TYPE=.*/TERM_TYPE=$term_type/g" "$netkit_conf"

echo "$terminal will now be used as Netkit's default terminal emulator."
