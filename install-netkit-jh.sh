#!/usr/bin/env bash

#     Copyright 2020-2021 Max Barstow, Adam Bromiley, Edwin Foudil, Joshua
#     Hawking, Peter Norris - Warwick Manufacturing Group, University of Warwick.
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


###############################################################################
# Write install-netkit-jh's usage line to standard output.
# Usage:
#   usage_line
# Globals:
#   r- SCRIPTNAME
# Arguments:
#   None
# Returns:
#   None
# Example:
#   None
###############################################################################
usage_line() {
   echo "Usage: $SCRIPTNAME [OPTION]..."
}


###############################################################################
# Write install-netkit-jh's usage as a full dialog or a "try --help".
# Usage:
#   usage STATUS
# Globals:
#   r- SCRIPTNAME
# Arguments:
#   $1 - status code to exit with. When zero, usage will write to standard
#        output and describe all options (for --help). Else, it will write to
#        standard error and be a brief usage and try-help message.
# Returns:
#   None - exits with a status code of STATUS
# Example:
#   None
###############################################################################
usage() {
   local status=$1

   if [ "$status" -ne 0 ]; then
      usage_line 1>&2
      try_help
      exit "$status"
   fi

   cat << END_OF_HELP
$(usage_line)
Install Netkit-JH $nk_version.

By default, the pre-built core of Netkit and its filesystem and kernel is
downloaded from the project's GitHub repository to the system's /tmp directory.
The archives are then extracted to the Netkit install directory
(\$HOME/netkit-jh/) and the shell's rc file is set accordingly to add the
install to PATH.

      --backup-dir=DIR  path to store a backup of the existing Netkit
                         installation
      --download-dir=DIR  download directory
      --download-url=URL  specify the directory to download the files from
                           as a URL
      --no-download   do not download pre-built Netkit modules if they are not
                        found inside the download directory
      --no-packages   do not download dependencies from APT
      --target-dir=DIR  directory to install Netkit to

For development purposes, the user may already have the pre-built components on
their system. The following options are provided for such a scenario (note that
DIR should be structured as if it were the install directory. As an example,
when using the --kernel-files option DIR must have a subdirectory named
kernel/):

      --core-files=DIR  path to core files if they have already been downloaded
                         and extracted
      --fs-files=DIR  path to filesystem files if they have already been
                        downloaded and extracted
      --kernel-files=DIR  path to kernel files if they have already been
                           downloaded and extracted


Miscellaneous:
$(help_option)
$(version_option)

END_OF_HELP

   exit "$status"
}


# Exit on a failed (non-zero return code) install command
set -e


SCRIPTNAME=$(basename -- "$0")


# ANSI color escape sequences
color_normal=$'\033[0m'
color_bold=$'\033[1m'


# Variable is initialised by Makefile
nk_version="VERSION_NUMBER"

install_dir="$HOME/netkit-jh"
backup_dir="$install_dir-$(date '+%F_%H-%M-%S')"

download_dir="/tmp"
download_url="https://github.com/netkit-jh/netkit-jh-build/releases/download/$nk_version/"


# Get command line options
long_opts="backup-dir:,core-files:,download-dir:,download-url:,fs-files:,help,\
kernel-files:,no-download,no-packages,target-dir:"
short_opts=""

if ! getopt_opts=$(getopt --name "$SCRIPTNAME" --options "$short_opts" --longoptions "$long_opts" -- "$@"); then
   # getopt will output the errorneous command-line argument
   usage 1
fi

# (Safely) set positional parameters to those reordered by getopt
eval set -- "$getopt_opts"

while true; do
   case $1 in
      --backup-dir)
         backup_dir=$(readlink --canonicalize-missing -- "$2")
         shift
         ;;
      --core-files)
         existing_core_files=$(readlink --canonicalize-missing -- "$2")
         shift
         ;;
      --download-dir)
         download_dir=$(readlink --canonicalize-missing -- "$2")
         shift
         ;;
      --download-url)
         download_url=$2
         shift
         ;;
      --fs-files)
         existing_fs_files=$(readlink --canonicalize-missing -- "$2")
         shift
         ;;
      --help)
         usage 0
         ;;
      --kernel-files)
         existing_kernel_files=$(readlink --canonicalize-missing -- "$2")
         shift
         ;;
      --no-download)
         no_download=1
         ;;
      --no-packages)
         no_packages=1
         ;;
      --target-dir)
         install_dir=$(readlink --canonicalize-missing -- "$2")
         shift
         ;;
      --version)
         echo "Netkit version: $nk_version"
         exit 0
         ;;
      --)
         shift
         break
         ;;
      *)
         echo 1>&2 "$SCRIPTNAME: Unknown error parsing command line arguments"
         usage 1
         ;;
   esac

   shift
done

# Check for further arguments
if [ $# -gt 0 ]; then
   echo 1>&2 "$SCRIPTNAME: Too many arguments"
   usage 1
fi


if [ -d "$install_dir/" ]; then
   # Backup existing directory
   echo "$install_dir: Directory exists; renaming to $backup_dir so contents are not disturbed"
   mv -- "$install_dir/" "$backup_dir/"
else
   mkdir --parents -- "$install_dir"
   unset backup_dir
fi


# Check whether they've specified extracted files
if [ -n "$existing_kernel_files" ] && [ -n "$existing_fs_files" ] && [ -n "$existing_core_files" ]; then
   cp --archive -- "$existing_kernel_files/." "$install_dir/"
   cp --archive -- "$existing_fs_files/."     "$install_dir/"
   cp --archive -- "$existing_core_files/."   "$install_dir/"
else
   release_files=(
      "release-$nk_version.sha256"
      "netkit-core-$nk_version.tar.bz2"
      "netkit-fs-$nk_version.tar.bz2"
      "netkit-kernel-$nk_version.tar.bz2"
   )

   mkdir --parents -- "$download_dir"

   for file in "${release_files[@]}"; do
      if [ -f "$download_dir/$file" ]; then
         echo "$download_dir/$file: file already exists; skipping"
         continue
      elif [ -n "$no_download" ]; then
         echo "$download_dir/$file: file does not exist and download has been disabled"
         exit 1
      fi

      wget --show-progress --output-document "$download_dir/$file" -- "$download_url/$file"
   done

   # Verify SHA-256 digests of each file. Files that failed the check will be
   # wrote to standard output of the subshell and hence into the corrupt_files
   # variable.
   corrupt_files=$(
      cd -- "$download_dir" || exit 1
      sha256sum --check --quiet "release-$nk_version.sha256" 2> /dev/null |
         cut --delimeter ":" --fields 1
   )

   if [ -n "$corrupt_files" ]; then
      echo 1>&2 "$SCRIPTNAME: $corrupt_files: File checksums failed verification; try downloading again"
      exit 1
   fi

   for file in "${release_files[@]}"; do
      # Extract the downloaded archives. The '--strip-components' option
      # removes the root netkit-jh/ directory.
      tar \
         --bzip2 \
         --extract \
         --verbose \
         --directory "$install_dir" \
         --strip-components 1 \
         -- \
         "$download_dir/$file"
   done
fi


# Start and end delimeters for Netkit-related stuff in the shell's rc file
rc_section_header="#=== NETKIT VARIABLES ==="
rc_section_footer="#=== NETKIT VARIABLES END ==="

# Environment variable definitions required for Netkit to run
nk_env_var_defs="export NETKIT_HOME=\"$install_dir\"
export MANPATH=\"\$MANPATH:\$NETKIT_HOME/man\"
export PATH=\"\$PATH:\$NETKIT_HOME/bin\""

rc_files=(
   "$HOME/.bashrc"
   "$HOME/.zshrc"
)

# Append Netkit additions to Bash and Zsh "run commands" files.
for rc_file in "${rc_files[@]}"; do
   [ ! -f "$rc_file" ] && continue
   
   # Backup existing rc file
   rc_file_bak="${rc_file}_$(date '+%F_%H-%M-%S').bak"
   cp -- "$rc_file" "$rc_file_bak"

   # Strip all content between the Netkit rc section header and footer
   sed --in-place "/^$rc_section_header/,/^$rc_section_footer/d;" "$rc_file"


   # Append Netkit additions to the rc file
   printf "%s\n" "$rc_section_header" >> "${rc_file}"

   # Environment variable definitions
   printf "%s\n" "$nk_env_var_defs" >> "${rc_file}"

   if [ "$(basename -- "$rc_file")" = ".bashrc" ]; then
      # Source the Bash completion scripts if operating on .bashrc
      cat << 'EOF' >> "$rc_file"

for file in "$NETKIT_HOME/bash-completion/completions/"*; do
   . "$file"
done
EOF
   fi

   # Terminate section with footer
   echo "$rc_section_footer"
done

# Ubuntu (and similar) distributions prevent .bashrc from running in a
# non-interactive shell. So here we can just evaluate the environment variables
# export commands
eval "$nk_env_var_defs"


# Download and install dependencies from APT
if [ -z "$no_packages" ]; then
   dependencies=(
      "bash"         # Required by every Netkit script
      "binutils"     # For objdump in 4_check_architecture.sh
      "coreutils"    # readlink, sha256sum, stdbuf, etc
      "curl"         # For update checking in lstart
      "iproute2"     # Interface management in manage_tuntap
      "iptables"     # To manage TUN/TAP traffic
      "lsof"         # To find unused virtual network hubs
      "make"         # Parallel lab start
      "net-tools"    # Interface management in manage_tuntap (TODO: iproute2)
      "util-linux"   # kill, getopt, mount, etc (should already be installed)
      "xterm"        # Default terminal emulator for Netkit
   )

   echo "Installing packages required to run Netkit-JH"
   sudo apt-get update
   sudo apt-get install "${dependencies[@]}"
fi


# Restore existing configuration file, if exists
if [ -n "$backup_dir" ]; then
   echo "Restoring previous configuration ($backup_dir/netkit.conf)"
   cp -- "$backup_dir/netkit.conf" "$install_dir"
fi


echo "${color_bold}Netkit-JH is now installed$color_normal"


# Verify system and Netkit install directory
echo "Checking configuration..."
"$install_dir/setup_scripts/check_configuration.sh" || exit 1

# Encourage user to set environment variables for the current terminal
cat << END_OF_DIALOG

${color_bold}To use Netkit-JH now, open a new terminal window or run:$color_normal
   source ~/.bashrc

(or .zshrc if using Zsh).

It is recommended to change the terminal emulator that Netkit uses, since the
default is xterm (an old but portable emulator). This can be done with the
folling command:
   "$install_dir/setup_scripts/change_terminal.sh"

or by manually setting the TERM_TYPE in one of the configuration files:
   (user)      "$HOME/.netkit/netkit.conf"
   (install)   "$install_dir/netkit.conf"
   (system)    /etc/netkit.conf
END_OF_DIALOG
