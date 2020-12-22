KERNEL_DIR=kernel
FS_DIR=fs
CORE_DIR=core

include Makefile.am

default: build-kernel build-fs build-core release.sha256 install-netkit-jh-${NETKIT_BUILD_RELEASE}.sh

.PHONY: build-fs
build-fs: ${FS_ARCHIVE_FILE}

.PHONY: build-kernel
build-kernel: ${KERNEL_ARCHIVE_FILE}

.PHONY: build-core
build-core: ${CORE_ARCHIVE_FILE}

${KERNEL_ARCHIVE_FILE}:
	$(MAKE)	-C ${KERNEL_DIR}

${FS_ARCHIVE_FILE}:
	$(MAKE) -C ${FS_DIR}

${CORE_ARCHIVE_FILE}:
	$(MAKE) -C ${CORE_DIR}

release.sha256:
	sha256sum ${FS_ARCHIVE_FILE} ${KERNEL_ARCHIVE_FILE} ${CORE_ARCHIVE_FILE} > release.sha256

install-netkit-jh-${NETKIT_BUILD_RELEASE}.sh:
	cp install-netkit-jh.sh install-netkit-jh-${NETKIT_BUILD_RELEASE}.sh
	sed -i "s/VERSION=\"VERSION_NUMBER\"/VERSION=\"${NETKIT_BUILD_RELEASE}\"/g" install-netkit-jh-${NETKIT_BUILD_RELEASE}.sh
	
.PHONY: clean
clean:
	$(MAKE) -C ${KERNEL_DIR} clean
	$(MAKE) -C ${FS_DIR} clean
	$(MAKE) -C ${CORE_DIR} clean
	rm -f release.sha256
	rm -f install-netkit-jh-${NETKIT_BUILD_RELEASE}.sh

.PHONY: mrproper
mrproper: clean
	$(MAKE) -C ${KERNEL_DIR} mrproper
	$(MAKE) -C ${FS_DIR} mrproper
	$(MAKE) -C ${CORE_DIR} mrproper
	rm -f release.sha256
	rm -f install-netkit-jh-${NETKIT_BUILD_RELEASE}.sh
