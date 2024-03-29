MAKEFILE_PATH := $(abspath $(lastword $(MAKEFILE_LIST)))
MAKEFILE_DIR := $(realpath $(dir $(MAKEFILE_PATH)))

include ../Makefile.am

# FS parameters
FS_FILE=netkit-fs-$(NETKIT_BUILD_RELEASE)
FS_RELEASE=bullseye
FS_SIZE=4G
DEBIAN_MIRROR=http://deb.debian.org/debian/

# Build parameters
BUILD_DIR=$(MAKEFILE_DIR)/build
NETKIT_DIR=$(BUILD_DIR)/netkit-jh
FS_DIR=$(NETKIT_DIR)/fs
MOUNT_DIR=$(BUILD_DIR)/mount-point

# Path to the build kernel modules
MODULES_PATH=../kernel/build/kernel_modules/

.DEFAULT_GOAL := $(FS_DIR)/$(FS_FILE)

.PHONY: clean
clean:
	umount $(MOUNT_DIR) || /bin/true
	rm -rf $(BUILD_DIR)
	rm -rf $(FS_DIR)
	rm -rf $(MOUNT_DIR)

.PHONY: mrproper
mrproper: clean
	rm -rf ../$(FS_ARCHIVE_FILE)

.PHONY: archive
archive: ../$(FS_ARCHIVE_FILE)

$(MODULES_PATH):
	$(error "No kernel modules found, please build the kernel before building the filesystem!")

$(BUILD_DIR)/bootstrap-fs:
	mkdir -p $(BUILD_DIR)
	mkdir -p $(FS_DIR)
	mkdir -p $(MOUNT_DIR)

	# Check directory isn't already mounted
	umount $(MOUNT_DIR) || /bin/true

	# Create an empty file FS_FILE and mount it to MOUNT_DIR
	dd if=/dev/zero of=$(BUILD_DIR)/bootstrap-fs bs=1 count=0 seek=$(FS_SIZE)
	mke2fs -F $(BUILD_DIR)/bootstrap-fs
	mount $(BUILD_DIR)/bootstrap-fs $(MOUNT_DIR)

	# Then debootstrap, installing to MOUNT_DIR
	debootstrap $(FS_RELEASE) $(MOUNT_DIR) $(DEBIAN_MIRROR)

$(FS_DIR)/$(FS_FILE): $(MODULES_PATH) $(BUILD_DIR)/bootstrap-fs
	# Update version
	echo "Netkit-JH filesystem version $(NETKIT_FS_RELEASE) ($(NETKIT_BUILD_RELEASE))" > $(FS_DIR)/netkit-filesystem-version

	# Run the install script, which will install packages, kernel modules and setup services
	$(MAKEFILE_DIR)/install-netkit-fs.sh $(MAKEFILE_DIR) $(FS_DIR) $(MOUNT_DIR) $(MODULES_PATH)

	# Unmount the directory
	umount $(MOUNT_DIR)

	# Now create the sparse filesystem and create symlink
	cp --sparse=always $(BUILD_DIR)/bootstrap-fs $(FS_DIR)/$(FS_FILE)
	cd $(FS_DIR) ; ln -sf $(FS_FILE) netkit-fs
	
../$(FS_ARCHIVE_FILE): $(FS_DIR)/$(FS_FILE)
	cd $(BUILD_DIR)/ ; tar -cvSjf ../../$(FS_ARCHIVE_FILE) netkit-jh/
