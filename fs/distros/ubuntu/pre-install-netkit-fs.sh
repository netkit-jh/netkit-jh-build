#!/bin/bash

# First argument is the work directory, that contains the packages list, package selections, service lists
WORK_DIRECTORY="$1"
# Second argument is the build directory, that contains the filesystem version file
BUILD_DIRECTORY="$2"
# Third argument is the directory which the filesystem is mounted at
MOUNT_DIRECTORY="$3"
# Fourth argument is the kernel module directory which should be copied
KERNEL_MODULES="$4"
# Fifth argument is the distro directory, that contains the packages list, package selections, service lists
DISTRO_DIRECTORY="$5"

# Load debconf-package-selections
cat $DISTRO_DIRECTORY/debconf-package-selections | chroot $MOUNT_DIRECTORY debconf-set-selections

# update package list
chroot $MOUNT_DIRECTORY apt update
chroot $MOUNT_DIRECTORY apt install --assume-yes software-properties-common
chroot $MOUNT_DIRECTORY add-apt-repository universe
chroot $MOUNT_DIRECTORY add-apt-repository multiverse
chroot $MOUNT_DIRECTORY apt update

# Now install any additional packages which require specific options
# We want wireguard without installing wireguard-dkms because we have it built into the kernel tree
chroot $MOUNT_DIRECTORY apt install --no-install-recommends wireguard-tools
