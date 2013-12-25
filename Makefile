KERNEL_DIR=kernel
FS_DIR=fs

include Makefile.am

default: build-kernel build-fs

.PHONY: build-fs
build-fs: ${FS_ARCHIVE_FILE}

.PHONY: build-kernel
build-kernel: ${KERNEL_ARCHIVE_FILE}

${KERNEL_ARCHIVE_FILE}:
	$(MAKE)	-C ${KERNEL_DIR}

${FS_ARCHIVE_FILE}:
	$(MAKE) -C ${FS_DIR}

.PHONY: clean
clean:
	$(MAKE) -C ${KERNEL_DIR} clean
	$(MAKE) -C ${FS_DIR} clean

.PHONY: mrproper
mrproper: clean
	$(MAKE) -C ${KERNEL_DIR} mrproper
	$(MAKE) -C ${FS_DIR} mrproper
