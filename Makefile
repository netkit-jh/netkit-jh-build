KERNEL_DIR=kernel
FS_DIR=fs

SUBARCH=i386

all: build-kernel build-fs

build-kernel:
	$(MAKE)	-C ${KERNEL_DIR} SUBARCH=${SUBARCH}

build-fs:
	$(MAKE) -C ${FS_DIR}
