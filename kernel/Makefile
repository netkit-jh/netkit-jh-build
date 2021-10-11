MAKEFILE_PATH := $(abspath $(lastword $(MAKEFILE_LIST)))
MAKEFILE_DIR := $(realpath $(dir $(MAKEFILE_PATH)))

include ../Makefile.am

# Kernel parameters
KERNEL_VERSION=5.14.9
KERNEL_URL=https://cdn.kernel.org/pub/linux/kernel/v5.x/linux-5.14.9.tar.xz
KERNEL_ARCHIVE_NAME=$$(echo "${KERNEL_URL}" | sed 's:.*/::')
KERNEL_FILE_EXTENSION=$$(echo "${KERNEL_ARCHIVE_NAME}" | sed 's:.*\.::')

# Build parameters
KERNEL_JOBS=$$(nproc)
BUILD_DIR=${MAKEFILE_DIR}/build
NETKIT_DIR=${BUILD_DIR}/netkit-jh
KERNEL_DIR=${NETKIT_DIR}/kernel

# To save downloading the same kernel archive every time, specify a directory to cache the download
CACHE_DIR=/tmp

.DEFAULT_GOAL := ${KERNEL_DIR}/netkit-kernel-${KERNEL_VERSION}

.PHONY: clean
clean:
	rm -rf ${BUILD_DIR}
	rm -rf /tmp/netkit-modules

.PHONY: mrproper
mrproper: clean
	rm -rf ../${KERNEL_ARCHIVE_FILE}

.PHONY: archive
archive: ../${KERNEL_ARCHIVE_FILE}

${BUILD_DIR}/linux-${KERNEL_VERSION}/downloaded.ready: 
	mkdir -p ${BUILD_DIR}
	mkdir -p /tmp/netkit-modules

	# If the file exists in the cache directory, copy it to our build directory
	# Otherwise, download it and copy it to the cache directory
	cd ${BUILD_DIR} ; test -f ${CACHE_DIR}/${KERNEL_ARCHIVE_NAME} && cp ${CACHE_DIR}/${KERNEL_ARCHIVE_NAME} . || wget ${KERNEL_URL} --output-document=${CACHE_DIR}/${KERNEL_ARCHIVE_NAME} && cp ${CACHE_DIR}/${KERNEL_ARCHIVE_NAME} ${KERNEL_ARCHIVE_NAME}
	# The file ending can be either .tar.xz (full-release) or .tar.gz (pre-release)
	# Some tar's (GNU tar) do not require additional flags, this is therefore just a compatibility check
	cd ${BUILD_DIR} ; test "${KERNEL_FILE_EXTENSION}" = "gz" && tar xzf ${KERNEL_ARCHIVE_NAME} || tar xJf ${KERNEL_ARCHIVE_NAME}

	touch ${BUILD_DIR}/linux-${KERNEL_VERSION}/downloaded.ready

# Compile the kernel
${BUILD_DIR}/linux-${KERNEL_VERSION}/linux: ${BUILD_DIR}/linux-${KERNEL_VERSION}/downloaded.ready
	# Apply our patches
	cd ${BUILD_DIR}/linux-${KERNEL_VERSION}; QUILT_PATCHES=../../patches quilt push -a

	# Copy in our kernel config
	cp uml-kernel-config ${BUILD_DIR}/linux-${KERNEL_VERSION}/.config

	# Configure kernel options
	$(MAKE) -C ${BUILD_DIR}/linux-${KERNEL_VERSION} oldconfig ARCH=um
	# Copy the updated kernel options out to our kernel directory
	cp ${BUILD_DIR}/linux-${KERNEL_VERSION}/.config last-uml-kernel-config
	# Compile kernel
	$(MAKE) -C ${BUILD_DIR}/linux-${KERNEL_VERSION} -j${KERNEL_JOBS} linux modules ARCH=um

	# Install modules into the /tmp/netkit-modules folder
	$(MAKE) -C ${BUILD_DIR}/linux-${KERNEL_VERSION} modules_install ARCH=um INSTALL_MOD_PATH=/tmp/netkit-modules

	# Copy kernel modules from netkit-modules into the netkit directory
	mkdir -p ${BUILD_DIR}/kernel_modules/
	cp -r /tmp/netkit-modules/lib/modules/* ${BUILD_DIR}/kernel_modules
	rm -rf /tmp/netkit-modules

# Create symlinks + named executable
${KERNEL_DIR}/netkit-kernel-${KERNEL_VERSION}: ${BUILD_DIR}/linux-${KERNEL_VERSION}/linux
	# Create symlinks
	mkdir -p ${KERNEL_DIR}
	cp ${BUILD_DIR}/linux-${KERNEL_VERSION}/linux ${KERNEL_DIR}/netkit-kernel-${KERNEL_VERSION}
	cd ${KERNEL_DIR} ; ln -s netkit-kernel-${KERNEL_VERSION} netkit-kernel

	# Update version
	echo "Netkit-JH UML version $(KERNEL_VERSION)" > ${KERNEL_DIR}/netkit-kernel-version

../${KERNEL_ARCHIVE_FILE}: ${KERNEL_DIR}/netkit-kernel-${KERNEL_VERSION}
	cd ${BUILD_DIR}/ ; tar -cvjf ../../${KERNEL_ARCHIVE_FILE} netkit-jh/
