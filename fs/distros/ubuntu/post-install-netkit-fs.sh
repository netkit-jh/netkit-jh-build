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


# We want iptables legacy, rather than nftables
chroot $MOUNT_DIRECTORY update-alternatives --set iptables /usr/sbin/iptables-legacy

# Save debconf-package-selections
chroot $MOUNT_DIRECTORY debconf-get-selections > $DISTRO_DIRECTORY/build/debconf-package-selections.last

# Empty caches
chroot $MOUNT_DIRECTORY apt clean
