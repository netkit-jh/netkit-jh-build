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


# Read user-defined Netkit configurations in reverse order of file localisation
# (per user, per install, per system).
# The variable term_type_netkit_conf stores the path of the most local
# netkit.conf file defining TERM_TYPE. This is only used in messages to the
# user.
# The variable netkit_conf stores the path of the most local netkit.conf file
# irrespective of whether it already sets TERM_TYPE or not. This will be used
# to declare the user's new chosen terminal emulator. By default, this is in
# $NETKIT_HOME.
# TODO: netkit_conf gets set to the most global netkit.conf. We want to set the
# most local one.
netkit_conf="$NETKIT_HOME/netkit.conf"

if [ -f "$HOME/.netkit/netkit.conf" ]; then
   # shellcheck disable=SC1091
   . -- "$HOME/.netkit/netkit.conf"
   netkit_conf="$HOME/.netkit/netkit.conf"
   [ -n "$TERM_TYPE" ] && term_type_netkit_conf=$netkit_conf
fi

if [ -z "$TERM_TYPE" ] && [ -f "$NETKIT_HOME/netkit.conf" ]; then
   # shellcheck source=../netkit.conf
   . -- "$NETKIT_HOME/netkit.conf"
   netkit_conf="$NETKIT_HOME/netkit.conf"
   [ -n "$TERM_TYPE" ] && term_type_netkit_conf=$netkit_conf
fi

if [ -z "$TERM_TYPE" ] && [ -f /etc/netkit.conf ]; then
   # shellcheck disable=SC1091
   . "/etc/netkit.conf"
   netkit_conf="/etc/netkit.conf"
   [ -n "$TERM_TYPE" ] && term_type_netkit_conf=$netkit_conf
fi

# Read default Netkit configuration if user has not overrode TERM_TYPE
if [ -z "$TERM_TYPE" ] && [ -f "$NETKIT_HOME/netkit.conf.default" ]; then
   # shellcheck source=../netkit.conf.default
   . -- "$NETKIT_HOME/netkit.conf.default"
   [ -n "$TERM_TYPE" ] && term_type_netkit_conf=$netkit_conf
fi


cat << END_OF_DIALOG
Current terminal emulator (TERM_TYPE): '$TERM_TYPE' ($term_type_netkit_conf)
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
         term_name="xterm"
         ;;
      2)
         if ! command -v -- "alacritty" > /dev/null 2>&1; then
            sudo add-apt-repository ppa:mmstick76/alacritty
            sudo apt-get update
            sudo apt-get install alacritty
         fi

         term_type="alacritty"
         term_name="Alacritty"
        ;;
      3)
         if ! command -v -- "kitty" > /dev/null 2>&1; then
            sudo apt-get update
            sudo apt-get install kitty
         fi

         term_type="kitty"
         term_name="kitty"
         ;;
      4)
         if ! command -v -- "gnome-terminal" > /dev/null 2>&1; then
            sudo apt-get update
            sudo apt-get install gnome-terminal
         fi

         term_type="gnome"
         term_name="GNOME Terminal"
         ;;
      5)
         if ! command -v -- "wsl.exe" > /dev/null 2>&1; then
            echo 1>&2 \
               "$SCRIPTNAME: wsl.exe: command not found. Is WSL configured to share environment variables with Windows?"
            exit 1
         fi

         term_type="wsl"
         term_name="Windows Console"
         ;;
      6)
         if ! command -v -- "wt.exe" > /dev/null 2>&1; then
            echo 1>&2 \
               "$SCRIPTNAME: wt.exe: command not found. Is WSL configured to share environment variables with Windows?"
            exit 1
         fi

         term_type="wt"
         term_name="Windows Terminal"
         ;;
   esac
done

# Change TERM_TYPE in netkit.conf or append it as a new option if not already
# defined.
comment="# Added by \$NETKIT_HOME\/setup_scripts\/change_terminal.sh"
sed \
   --in-place \
   -- \
   "/^TERM_TYPE=/{h;s/=.*/=$term_type/};\${x;/^$/{s//\n$comment\nTERM_TYPE=$term_type/;H};x}" \
   "$netkit_conf"

echo "$term_name will now be used as Netkit's default terminal emulator."
