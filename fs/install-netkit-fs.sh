#!/bin/bash

# First argument is the work directory (the fs directory)
WORK_DIRECTORY="$1"
# Second argument is the build directory, that contains the filesystem version file
BUILD_DIRECTORY="$2"
# Third argument is the directory which the filesystem is mounted at
MOUNT_DIRECTORY="$3"
# Fourth argument is the kernel module directory which should be copied
KERNEL_MODULES="$4"
# Fifth argument is the distro directory, that contains the packages list, package selections, service lists
DISTRO_DIRECTORY="$5"

whoami

source $DISTRO_DIRECTORY/distro.env

# Install packages in packages-list
PACKAGES_LIST=`cat $DISTRO_DIRECTORY/packages-list | grep -v '#'`
echo "Installing packages with command $INSTALL_COMMAND"

for package in ${PACKAGES_LIST}; do
    chroot $MOUNT_DIRECTORY $INSTALL_COMMAND $package
done


# Copy netkit filesystem files
tar -C $WORK_DIRECTORY/filesystem-tweaks -c . | tar --overwrite --same-owner -C $MOUNT_DIRECTORY -x
# Copy distro specific tweaks
mkdir -p $DISTRO_DIRECTORY/filesystem-tweaks # make dir in case it doesnt exist
tar -C $DISTRO_DIRECTORY/filesystem-tweaks -c . | tar --overwrite --same-owner -C $MOUNT_DIRECTORY -x

# Copy in version file
cp $BUILD_DIRECTORY/netkit-filesystem-version $MOUNT_DIRECTORY/etc/netkit-filesystem-version

# Create kernel module directory
mkdir -p $MOUNT_DIRECTORY/lib/modules

# Copy in kernel modules (kernel modules can instead by mounted at runtime by enabling the netkit-mount service)
cp -r $KERNEL_MODULES/* $MOUNT_DIRECTORY/lib/modules/

# Install netkit services
chroot $MOUNT_DIRECTORY systemctl enable netkit-startup-phase1.service
chroot $MOUNT_DIRECTORY systemctl enable netkit-startup-phase2.service
chroot $MOUNT_DIRECTORY systemctl enable netkit-shutdown.service

# Required for mounting kernel modules at runtime
#chroot $MOUNT_DIRECTORY systemctl enable netkit-mount.service
#chroot $MOUNT_DIRECTORY systemctl enable netkit-unmount.service

# Disable system services not required
for SERVICE in `cat $DISTRO_DIRECTORY/disabled-services`; do
	chroot $MOUNT_DIRECTORY systemctl disable ${SERVICE}
done

for SERVICE in `cat $DISTRO_DIRECTORY/enabled-services`; do
	chroot $MOUNT_DIRECTORY systemctl enable ${SERVICE}
done

# Add random-seed entropy
dd if=/dev/urandom of=$MOUNT_DIRECTORY/var/lib/systemd/random-seed bs=2048 count=1
