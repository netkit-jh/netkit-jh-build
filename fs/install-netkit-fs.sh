#!/usr/bin/env bash

set -e 

export LC_ALL=C 

# First argument is the work directory, that contains the packages list, package selections, service lists
WORK_DIRECTORY="$1"
# Second argument is the build directory, that contains the filesystem version file
BUILD_DIRECTORY="$2"
# Third argument is the directory which the filesystem is mounted at
MOUNT_DIRECTORY="$3"
# Forth argument is the kernel module directory which should be copied
KERNEL_MODULES="$4"

# Load debconf-package-selections
cat $WORK_DIRECTORY/debconf-package-selections | chroot $MOUNT_DIRECTORY debconf-set-selections

# Install packages in packages-list
PACKAGES_LIST=$(cat $WORK_DIRECTORY/packages-list | grep -v '#')

# Install add-apt-repository command
chroot $MOUNT_DIRECTORY apt update
chroot $MOUNT_DIRECTORY apt install --assume-yes software-properties-common

# Install custom repositories
# chroot $MOUNT_DIRECTORY add-apt-repository ppa:cz.nic-labs/bird  # for Bird Internet routing daemon

# Install packages inside packages_list
chroot $MOUNT_DIRECTORY apt update
chroot $MOUNT_DIRECTORY apt install --assume-yes ${PACKAGES_LIST}

# Now install any additional packages which require specific options
# We want wireguard without installing wireguard-dkms because we have it built into the kernel tree
chroot $MOUNT_DIRECTORY apt install --no-install-recommends wireguard-tools

# We want iptables legacy, rather than nftables
chroot $MOUNT_DIRECTORY update-alternatives --set iptables /usr/sbin/iptables-legacy

# Copy netkit filesystem files
# we want to keep the destination mode/ownership (--no-preserve)
# we want to keep symlinks and not de-reference them (-d)
cp -r --no-preserve=mode,ownership -d $WORK_DIRECTORY/filesystem-tweaks/* $MOUNT_DIRECTORY/

# However, some files in filesystem tweaks do need to be executable, so we set them again here
chmod +x $MOUNT_DIRECTORY/usr/local/bin/tcpdump $MOUNT_DIRECTORY/etc/netkit/*

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

# Sort out ttys and auto-logon
ln -s $MOUNT_DIRECTORY/lib/systemd/system/getty@.service $MOUNT_DIRECTORY/etc/systemd/system/getty.target.wants/getty@tty0.service

chroot $MOUNT_DIRECTORY systemctl mask getty-static

for i in {2..6}; do
  chroot $MOUNT_DIRECTORY systemctl mask getty@tty${i}.service
done

# Required for mounting kernel modules at runtime
#chroot $MOUNT_DIRECTORY systemctl enable netkit-mount.service
#chroot $MOUNT_DIRECTORY systemctl enable netkit-unmount.service

# Disable system services not required
for SERVICE in $(cat $WORK_DIRECTORY/disabled-services); do
  chroot $MOUNT_DIRECTORY systemctl disable ${SERVICE}
done

# Set root to use no password
chroot $MOUNT_DIRECTORY passwd -d root

# Update SSH keys in /etc/ssh to remove builder's hostname
sed -i "s/$(whoami)@$(hostname)/root@netkit/g" $MOUNT_DIRECTORY/etc/ssh/*.pub

# Save debconf-package-selections
(chroot $MOUNT_DIRECTORY debconf-get-selections) > $WORK_DIRECTORY/build/debconf-package-selections.last

# Empty caches
chroot $MOUNT_DIRECTORY apt clean

# Delete bootstrap log
rm -f $MOUNT_DIRECTORY/var/log/bootstrap.log
