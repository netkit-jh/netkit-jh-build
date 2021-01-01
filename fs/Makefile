MAKEFILE_PATH := $(abspath $(lastword $(MAKEFILE_LIST)))
MAKEFILE_DIR := $(dir $(MAKEFILE_PATH))

include ../Makefile.am

BUILD_DIR=build
CACHE_DIR=cache
FINAL_ARCHIVE=../${FS_ARCHIVE_FILE}
NETKIT_DIR=${BUILD_DIR}/netkit-ng
FS_DIR=${NETKIT_DIR}/fs
MODULES_PATH=../kernel/build/kernel_modules/

FS_FILE_NAME=netkit-fs-${NETKIT_BUILD_RELEASE}
FS_RELEASE=bullseye
DEBIAN_MIRROR=http://ftp.uk.debian.org/debian
# 4M = 4 gigabytes, 1M = 1 gigabyte
FS_SIZE=4M
MOUNT_DIRECTORY=${BUILD_DIR}/mount-point

default: ${FINAL_ARCHIVE}

.PHONY: clean
clean:
	umount ${MOUNT_DIRECTORY} || /bin/true
	rm -rf ${BUILD_DIR}

.PHONY: mrproper
mrproper: clean
	rm -rf ${CACHE_DIR}
	rm -rf ${FINAL_ARCHIVE}

.PHONY: init
init: clean
	mkdir -p ${FS_DIR}

${FINAL_ARCHIVE}: init ${FS_FILE_NAME} ${MODULES_PATH}
	# cp -r ${MODULES_PATH} ${BUILD_DIR}
	echo "Netkit-JH filesystem version ${NETKIT_FS_RELEASE} (${NETKIT_BUILD_RELEASE})" > ${FS_DIR}/netkit-filesystem-version
	
	# Run the install script, which will install packages, kernel modules and setup services
	${MAKEFILE_DIR}/install-netkit-fs.sh ${MAKEFILE_DIR} ${FS_DIR} ${MOUNT_DIRECTORY} ${MODULES_PATH}
	
	# Unmount the directory
	umount ${MOUNT_DIRECTORY}

	# Now create required symlinks and tar the filesystem
	cd ${FS_DIR} ; ln -s ${FS_FILE_NAME} netkit-fs
	mv ${FS_DIR}/${FS_FILE_NAME} ${FS_DIR}/${FS_FILE_NAME}.old
	cp --sparse=always ${FS_DIR}/${FS_FILE_NAME}.old ${FS_DIR}/${FS_FILE_NAME}
	rm -f ${FS_DIR}/${FS_FILE_NAME}.old
	cd ${BUILD_DIR}/ ; tar -cvSjf ../${FINAL_ARCHIVE} netkit-ng/

${FS_FILE_NAME}:
	mkdir -p ${BUILD_DIR}
	mkdir -p ${MOUNT_DIRECTORY}
	
	# Create an empty file FS_FILE_NAME and mount it to MOUNT_DIRECTORY
	dd if=/dev/zero of=${FS_DIR}/${FS_FILE_NAME} bs=${FS_SIZE} count=1024
	mke2fs -F ${FS_DIR}/${FS_FILE_NAME}
	mount ${FS_DIR}/${FS_FILE_NAME} ${MOUNT_DIRECTORY} 
	
	# Then debootstrap, installing to MOUNT_DIRECTORY
	debootstrap ${FS_RELEASE} ${MOUNT_DIRECTORY} ${DEBIAN_MIRROR}

