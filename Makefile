MAKEFILE_PATH := $(abspath $(lastword $(MAKEFILE_LIST)))
MAKEFILE_DIR := $(realpath $(dir $(MAKEFILE_PATH)))

include Makefile.am

KERNEL_DIR=kernel
FS_DIR=fs
CORE_DIR=core

INSTALL_LOCATION ?= $(HOME)/netkit-jh

default: build-kernel build-fs build-core

.PHONY: build-kernel
build-kernel: 
	$(MAKE)	-C ${KERNEL_DIR}

.PHONY: build-fs
build-fs: 
	$(MAKE)	-C ${FS_DIR}

.PHONY: build-core
build-core: 
	$(MAKE)	-C ${CORE_DIR}

.PHONY: archives
archives: ${KERNEL_ARCHIVE_FILE} ${FS_ARCHIVE_FILE} ${CORE_ARCHIVE_FILE}

.PHONY: file-hashes
file-hashes: release-${NETKIT_BUILD_RELEASE}.sha256

.PHONY: install-script
install-script: install-netkit-jh-${NETKIT_BUILD_RELEASE}.sh

.PHONY: release
release: archives file-hashes install-script

${KERNEL_ARCHIVE_FILE}:
	$(MAKE)	-C ${KERNEL_DIR} archive

${FS_ARCHIVE_FILE}:
	$(MAKE) -C ${FS_DIR} archive

${CORE_ARCHIVE_FILE}:
	$(MAKE) -C ${CORE_DIR} archive

release-${NETKIT_BUILD_RELEASE}.sha256:
	sha256sum ${FS_ARCHIVE_FILE} ${KERNEL_ARCHIVE_FILE} ${CORE_ARCHIVE_FILE} > release-${NETKIT_BUILD_RELEASE}.sha256

install-netkit-jh-${NETKIT_BUILD_RELEASE}.sh:
	cp install-netkit-jh.sh install-netkit-jh-${NETKIT_BUILD_RELEASE}.sh
	chmod +x install-netkit-jh-${NETKIT_BUILD_RELEASE}.sh
	sed -i "s/VERSION=\"VERSION_NUMBER\"/VERSION=\"${NETKIT_BUILD_RELEASE}\"/g" install-netkit-jh-${NETKIT_BUILD_RELEASE}.sh
	
.PHONY: clean
clean:
	$(MAKE) -C ${KERNEL_DIR} clean
	$(MAKE) -C ${FS_DIR} clean
	$(MAKE) -C ${CORE_DIR} clean

.PHONY: mrproper
mrproper: clean
	$(MAKE) -C ${KERNEL_DIR} mrproper
	$(MAKE) -C ${FS_DIR} mrproper
	$(MAKE) -C ${CORE_DIR} mrproper
	rm -f release-${NETKIT_BUILD_RELEASE}.sha256
	rm -f install-netkit-jh-${NETKIT_BUILD_RELEASE}.sh

.PHONY: install
install: ${KERNEL_ARCHIVE_FILE} ${FS_ARCHIVE_FILE} ${CORE_ARCHIVE_FILE} install-script
ifeq ($(shell id -u), 0)
		@echo "Please run 'make install' without root privileges. You will be asked when appropiate to use root privileges."
		exit 1
endif
	
	@echo "Install location: ${INSTALL_LOCATION}"
	
	./install-netkit-jh-${NETKIT_BUILD_RELEASE}.sh --no-download --no-packages --kernel-files=${MAKEFILE_DIR}/${KERNEL_DIR}/build/netkit-jh --core-files=${MAKEFILE_DIR}/${CORE_DIR}/build/netkit-jh --fs-files=${MAKEFILE_DIR}/${FS_DIR}/build/netkit-jh --target-dir="$(INSTALL_LOCATION)"
	
