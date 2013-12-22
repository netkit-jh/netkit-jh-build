BUILD_DIR=../build/kernel/
KERNEL_VERSION=user-mode-linux-3.2-2um
NETKIT_KERNEL_RELEASE=$(shell awk '/kernel version/ {print $$NF}' netkit-kernel-version)

all: pack

clean:
	rm -rf ${BUILD_DIR}

init:
	mkdir -p ${BUILD_DIR}

kernel: init
	cd ${BUILD_DIR} ; apt-get source user-mode-linux
	cd ${BUILD_DIR} ; apt-get build-dep user-mode-linux
	sed 's/CONFIG_LOCALVERSION=.*/CONFIG_LOCALVERSION="-netkit-$(NK_KERNEL_RELEASE)"/' config.i386 > ${BUILD_DIR}/${KERNEL_VERSION}/config.i386
	cp patches/* ${BUILD_DIR}/${KERNEL_VERSION}/debian/patches/
	cd ${BUILD_DIR}/${KERNEL_VERSION}/ ; dpkg-buildpackage -rfakeroot -nc -uc

pack: kernel
	mkdir -p ${BUILD_DIR}/netkit/kernel
	cp ${BUILD_DIR}/${KERNEL_VERSION}/debian/user-mode-linux/usr/bin/linux.uml ${BUILD_DIR}/netkit/kernel/netkython-kernel-i386-3.2.51-K3.0
	cd ${BUILD_DIR}/netkit/kernel/ ; ln -s netkython-kernel-i386-3.2.51-${NETKIT_KERNEL_RELEASE} netkit-kernel
	mkdir -p ${BUILD_DIR}/netkit/kernel/modules/
	cp -r ${BUILD_DIR}/${KERNEL_VERSION}/debian/user-mode-linux/usr/lib/ -p ${BUILD_DIR}/netkit/kernel/modules/
	cd ${BUILD_DIR}/ ; tar cvjf ../../netkython-kernel-i386-${NETKIT_KERNEL_RELEASE}.tar.bz2 netkit/

