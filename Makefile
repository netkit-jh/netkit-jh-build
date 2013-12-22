BUILD_DIR=build
KERNEL_DIR=kernel
FS_DIR=fs

all: init build-kernel build-fs

clean:
	rm -rf ${BUILD_DIR}

init: clean
	mkdir ${BUILD_DIR}

build-kernel:
	$(MAKE)	-C ${KERNEL_DIR}

build-fs:
	$(MAKE) -C ${FS_DIR}
