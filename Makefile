KERNEL_DIR=kernel
FS_DIR=fs

all: build-kernel build-fs

build-kernel:
	$(MAKE)	-C ${KERNEL_DIR}

build-fs:
	$(MAKE) -C ${FS_DIR}
