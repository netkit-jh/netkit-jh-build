NETKIT_KERNEL_RELEASE=K3.0
KERNEL_VERSION=user-mode-linux-3.2-2um
KERNEL_NUMBER=3.2.51

BUILD_DIR=../build/kernel
DEBIAN_PACKAGE_DIR=${BUILD_DIR}/${KERNEL_VERSION}

FINAL_ARCHIVE=../../netkit-kernel-i386-${NETKIT_KERNEL_RELEASE}.tar.bz2

all: ${FINAL_ARCHIVE}

clean:
	rm -rf ${BUILD_DIR}

init: clean
	mkdir -p ${BUILD_DIR}

${DEBIAN_PACKAGE_DIR}: init
	cd ${BUILD_DIR} ; apt-get source user-mode-linux
	cd ${BUILD_DIR} ; apt-get build-dep user-mode-linux

${DEBIAN_PACKAGE_DIR}/debian/user-mode-linux/usr/bin/linux.uml: ${DEBIAN_PACKAGE_DIR}
	sed 's/CONFIG_LOCALVERSION=.*/CONFIG_LOCALVERSION="-netkit-$(NETKIT_KERNEL_RELEASE)"/' config.i386 > ${BUILD_DIR}/${KERNEL_VERSION}/config.${SUBARCH}
	cp patches/* ${DEBIAN_PACKAGE_DIR}/debian/patches/
	cd ${DEBIAN_PACKAGE_DIR} ; dpkg-buildpackage -rfakeroot -nc -uc

${FINAL_ARCHIVE}: ${DEBIAN_PACKAGE_DIR}/debian/user-mode-linux/usr/bin/linux.uml
	mkdir -p ${BUILD_DIR}/netkit/kernel
	cp ${DEBIAN_PACKAGE_DIR}/debian/user-mode-linux/usr/bin/linux.uml ${BUILD_DIR}/netkit/kernel/netkit-kernel-i386-3.2.51-K3.0
	cd ${BUILD_DIR}/netkit/kernel/ ; ln -s netit-kernel-${SUBARCH}-${KERNEL_NUMBER}-${NETKIT_KERNEL_RELEASE} netkit-kernel
	mkdir -p ${BUILD_DIR}/netkit/kernel/modules/
	cp -r ${DEBIAN_PACKAGE_DIR}/debian/user-mode-linux/usr/lib/ ${BUILD_DIR}/netkit/kernel/modules/
	echo "Netkit kernel version $(NETKIT_KERNEL_RELEASE)" > ${BUILD_DIR}/netkit/kernel/netkit-kernel-version
	cd ${BUILD_DIR}/ ; tar cvjf ${FINAL_ARCHIVE} netkit/

