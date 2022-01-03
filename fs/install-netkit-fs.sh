#!/usr/bin/env bash

#     Copyright 2020-2022 Max Barstow, Adam Bromiley, Joshua Hawking, Luke
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
mnt_point=$3

# Kernel module directory to copy into the filesystem at /lib/modules
kernel_modules=$4


### INSTALL APT PACKAGES ######################################################
# Load debconf-package-selections
chroot -- "$mnt_point" debconf-set-selections < "$work_dir/debconf-package-selections"

# Install add-apt-repository command
chroot -- "$mnt_point" apt-get update
chroot -- "$mnt_point" apt-get --assume-yes install software-properties-common

# Add additional repositories in this section
# chroot -- "$mnt_point" add-apt-repository ...
# chroot -- "$mnt_point" apt-get update

# Install packages listed in packages-list
mapfile -t packages_list < <(grep --invert-match -- "^#" "$work_dir/packages-list")
chroot -- "$mnt_point" apt-get --assume-yes -- install "${packages_list[@]}"

# Install packages which require specific APT options
# We want wireguard without installing wireguard-dkms because we have it built
# into the kernel tree.
chroot -- "$mnt_point" apt-get --no-install-recommends install wireguard-tools

# Install legacy iptables over nftables
chroot -- "$mnt_point" update-alternatives --set iptables /usr/sbin/iptables-legacy


### COPY OVER PRECONFIGURED FILES FOR NETKIT ##################################
# Copy preconfigured files into the filesystem, overriding with the destination
# permissions/ownership (--no-preserve) and keeping symlinks (--no-dereference
# --preserve=links).
cp \
   --recursive \
   --no-preserve=mode,ownership \
   --no-dereference \
   --preserve=links \
   --target-directory "$mnt_point" \
   -- \
   "$work_dir/filesystem-tweaks/"*

# Some files in filesystem-tweaks need to be executable, so we set their mode
# correctly here.
fs_tweaks_executables=(
   "$mnt_point/usr/local/bin/tcpdump"
   "$mnt_point/etc/netkit/"*
)
chmod -- +x "${fs_tweaks_executables[@]}"

# Copy the version file in
cp -- "$build_dir/netkit-filesystem-version" "$mnt_point/etc/netkit-filesystem-version"


### MANAGE SERVICES ###########################################################
# Enable Netkit services
chroot -- "$mnt_point" systemctl enable \
   netkit-startup-phase1.service \
   netkit-startup-phase2.service \
   netkit-shutdown.service

# Sort out ttys and auto-logon
ln \
   --symbolic \
   -- \
   "$mnt_point/lib/systemd/system/getty@.service" \
   "$mnt_point/etc/systemd/system/getty.target.wants/getty@tty0.service"

chroot -- "$mnt_point" systemctl mask getty-static "getty@tty"{2..6}".service"

# Disable autostart for some services
mapfile -t disabled_services < <(grep --invert-match -- "^#" "$work_dir/disabled-services")
chroot -- "$mnt_point" systemctl disable "${disabled_services[@]}"


### INSTALL KERNEL MODULES ####################################################
# Create kernel module directory
mkdir --parents -- "$mnt_point/lib/modules"

# Copy in kernel modules (kernel modules can instead by mounted at runtime by
# enabling the netkit-mount service).
cp --recursive -- "$kernel_modules/"* "$mnt_point/lib/modules/"

# Required for mounting kernel modules at runtime
# chroot -- "$mnt_point" systemctl enable netkit-mount.service
# chroot -- "$mnt_point" systemctl enable netkit-unmount.service


### USER MANAGEMENT ###########################################################
# Set root to use no password
chroot -- "$mnt_point" passwd --delete root

# Update SSH keys in /etc/ssh to remove builder's hostname
sed --in-place -- "s/$(whoami)@$(hostname)/root@netkit/g" "$mnt_point/etc/ssh/"*.pub


### CLEANUP ###################################################################
# Save debconf-package-selections
chroot -- "$mnt_point" debconf-get-selections > "$work_dir/build/debconf-package-selections.last"

# Empty package cache
chroot -- "$mnt_point" apt-get clean

# Delete bootstrap log
rm --force -- "$mnt_point/var/log/bootstrap.log"
