#!/usr/bin/env bash

#     Copyright 2020-2021 Max Barstow, Adam Bromiley, Joshua Hawking, Luke
#     Spademan - Warwick Manufacturing Group, University of Warwick.
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

# Initialise the Netkit filesystem by installing packages, kernel modules, and
# setting up critical services.


set -e


# Override locale to avoid localization errors
export LC_ALL=C 


# First argument is the current working directory. At its top level, there
# should be the following:
#    packages-list
#       - List of APT packages to install on the filesystem.
#    disabled-services
#       - List of services to disable autostart for.
#    debconf-package-selections
#       - Package configuration data suitable for input to
#         debconf-set-selections.
#    filesystem-tweaks
#       - A directory with the same structure as the to-be-produced filesystem.
#         Any file present will be copied into the filesystem at the same
#         location (and overwrite any existing file).
work_dir=$1

# Build directory that contains the netkit-filesystem-version file
build_dir=$2

# Mount point of the filesystem
mount_dir=$3

# Kernel module directory to copy into the filesystem at /lib/modules
kernel_modules=$4


### INSTALL APT PACKAGES ######################################################
# Load debconf-package-selections
chroot -- "$mount_dir" debconf-set-selections < "$work_dir/debconf-package-selections"

# Install add-apt-repository command
chroot -- "$mount_dir" apt-get update
chroot -- "$mount_dir" apt-get --assume-yes install software-properties-common

# Add additional repositories in this section
# chroot -- "$mount_dir" add-apt-repository ...
# chroot -- "$mount_dir" apt-get update

# Install packages listed in packages-list
mapfile -t packages_list < <(grep --invert-match -- "^#" "$work_dir/packages-list")
chroot -- "$mount_dir" apt-get --assume-yes -- install "${packages_list[@]}"

# Install packages which require specific APT options
# We want wireguard without installing wireguard-dkms because we have it built
# into the kernel tree.
chroot -- "$mount_dir" apt-get --no-install-recommends install wireguard-tools

# Install legacy iptables over nftables
chroot -- "$mount_dir" update-alternatives --set iptables /usr/sbin/iptables-legacy


### COPY OVER PRECONFIGURED FILES FOR NETKIT ##################################
# Copy preconfigured files into the filesystem, overriding with the destination
# permissions/ownership (--no-preserve) and keeping symlinks (--no-dereference
# --preserve=links).
cp \
   --recursive \
   --no-preserve=mode,ownership \
   --no-dereference \
   --preserve=links \
   --target-directory "$mount_dir" \
   -- \
   "$work_dir/filesystem-tweaks/"*

# Some files in filesystem-tweaks need to be executable, so we set their mode
# correctly here.
fs_tweaks_executables=(
   "$mount_dir/usr/local/bin/tcpdump"
   "$mount_dir/etc/netkit/"*
)
chmod -- +x "${fs_tweaks_executables[@]}"

# Copy the version file in
cp -- "$build_dir/netkit-filesystem-version" "$mount_dir/etc/netkit-filesystem-version"


### MANAGE SERVICES ###########################################################
# Enable Netkit services
chroot -- "$mount_dir" systemctl enable \
   netkit-startup-phase1.service \
   netkit-startup-phase2.service \
   netkit-shutdown.service

# Sort out ttys and auto-logon
ln \
   --symbolic \
   -- \
   "$mount_dir/lib/systemd/system/getty@.service" \
   "$mount_dir/etc/systemd/system/getty.target.wants/getty@tty0.service"

chroot -- "$mount_dir" systemctl mask getty-static "getty@tty"{2..6}".service"

# Disable autostart for some services
mapfile -t disabled_services < <(grep --invert-match -- "^#" "$work_dir/disabled-services")
chroot -- "$mount_dir" systemctl disable "${disabled_services[@]}"


### INSTALL KERNEL MODULES ####################################################
# Create kernel module directory
mkdir --parents -- "$mount_dir/lib/modules"

# Copy in kernel modules (kernel modules can instead by mounted at runtime by
# enabling the netkit-mount service).
cp --recursive -- "$kernel_modules/"* "$mount_dir/lib/modules/"

# Required for mounting kernel modules at runtime
# chroot -- "$mount_dir" systemctl enable netkit-mount.service
# chroot -- "$mount_dir" systemctl enable netkit-unmount.service


### USER MANAGEMENT ###########################################################
# Set root to use no password
chroot -- "$mount_dir" passwd --delete root

# Update SSH keys in /etc/ssh to remove builder's hostname
sed --in-place -- "s/$(whoami)@$(hostname)/root@netkit/g" "$mount_dir/etc/ssh/"*.pub


### CLEANUP ###################################################################
# Save debconf-package-selections
chroot -- "$mount_dir" debconf-get-selections > "$work_dir/build/debconf-package-selections.last"

# Empty package cache
chroot -- "$mount_dir" apt-get clean

# Delete bootstrap log
rm --force -- "$mount_dir/var/log/bootstrap.log"
