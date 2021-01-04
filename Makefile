KERNEL_DIR=kernel
FS_DIR=fs
CORE_DIR=core

include Makefile.am

default: build-kernel build-fs build-core file-hashes install-script

.PHONY: build-fs
build-fs: ${FS_ARCHIVE_FILE}

.PHONY: build-kernel
build-kernel: ${KERNEL_ARCHIVE_FILE}

.PHONY: build-core
build-core: ${CORE_ARCHIVE_FILE}

.PHONY: file-hashes
file-hashes: release-${NETKIT_BUILD_RELEASE}.sha256

.PHONY: install-script
install-script: install-netkit-jh-${NETKIT_BUILD_RELEASE}.sh

${KERNEL_ARCHIVE_FILE}:
	$(MAKE)	-C ${KERNEL_DIR}

${FS_ARCHIVE_FILE}:
	$(MAKE) -C ${FS_DIR}

${CORE_ARCHIVE_FILE}:
	$(MAKE) -C ${CORE_DIR}

release-${NETKIT_BUILD_RELEASE}.sha256:
	sha256sum ${FS_ARCHIVE_FILE} ${KERNEL_ARCHIVE_FILE} ${CORE_ARCHIVE_FILE} > release-${NETKIT_BUILD_RELEASE}.sha256

install-netkit-jh-${NETKIT_BUILD_RELEASE}.sh:
	cp install-netkit-jh.sh install-netkit-jh-${NETKIT_BUILD_RELEASE}.sh
	sed -i "s/VERSION=\"VERSION_NUMBER\"/VERSION=\"${NETKIT_BUILD_RELEASE}\"/g" install-netkit-jh-${NETKIT_BUILD_RELEASE}.sh
	
.PHONY: clean
clean:
	$(MAKE) -C ${KERNEL_DIR} clean
	$(MAKE) -C ${FS_DIR} clean
	$(MAKE) -C ${CORE_DIR} clean
	rm -f release-${NETKIT_BUILD_RELEASE}.sha256
	rm -f install-netkit-jh-${NETKIT_BUILD_RELEASE}.sh

.PHONY: mrproper
mrproper: clean
	$(MAKE) -C ${KERNEL_DIR} mrproper
	$(MAKE) -C ${FS_DIR} mrproper
	$(MAKE) -C ${CORE_DIR} mrproper
	rm -f release-${NETKIT_BUILD_RELEASE}.sha256
	rm -f install-netkit-jh-${NETKIT_BUILD_RELEASE}.sh
	
.PHONY: install
install: ${KERNEL_ARCHIVE_FILE} ${FS_ARCHIVE_FILE} ${CORE_ARCHIVE_FILE} file-hashes install-script
ifeq ($(shell id -u), 0)
		@echo "Please run 'make install' without root privileges. You will be asked when appropiate to use root privileges."
		exit 1
endif

	# Modify download directory for install script to be makefile directory
	sed -i "s/DOWNLOAD_DIR=\".*\"/DOWNLOAD_DIR=\"\.\"/g" install-netkit-jh-${NETKIT_BUILD_RELEASE}.sh
	
	chmod +x install-netkit-jh-${NETKIT_BUILD_RELEASE}.sh
	./install-netkit-jh-${NETKIT_BUILD_RELEASE}.sh
	
