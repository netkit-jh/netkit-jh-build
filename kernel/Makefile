include ../Makefile.am

KERNEL_VERSION=user-mode-linux-3.2-2um
KERNEL_NUMBER=3.2.51

BUILD_DIR=build
NETKIT_DIR=${BUILD_DIR}/netkit-ng
KERNEL_DIR=${NETKIT_DIR}/kernel
DEBIAN_PACKAGE_DIR=${BUILD_DIR}/${KERNEL_VERSION}

default: ../${KERNEL_ARCHIVE_FILE}

.PHONY: clean
clean:
	rm -rf ${BUILD_DIR}

.PHONY: mrproper
mrproper: clean
	rm -rf ../${KERNEL_ARCHIVE_FILE}

.PHONY: init
init: clean
	mkdir -p ${BUILD_DIR}

${DEBIAN_PACKAGE_DIR}: init
	cd ${BUILD_DIR} ; apt-get source user-mode-linux
	cd ${BUILD_DIR} ; apt-get build-dep user-mode-linux

${DEBIAN_PACKAGE_DIR}/debian/user-mode-linux/usr/bin/linux.uml: ${DEBIAN_PACKAGE_DIR}
	sed 's/CONFIG_LOCALVERSION=.*/CONFIG_LOCALVERSION="-netkit-ng-$(NETKIT_KERNEL_RELEASE)"/' config.i386 > ${BUILD_DIR}/${KERNEL_VERSION}/config.${SUBARCH}
	cp patches/* ${DEBIAN_PACKAGE_DIR}/debian/patches/
	cd ${DEBIAN_PACKAGE_DIR} ; dpkg-buildpackage -rfakeroot -nc -uc

../${KERNEL_ARCHIVE_FILE}: ${DEBIAN_PACKAGE_DIR}/debian/user-mode-linux/usr/bin/linux.uml
	mkdir -p ${KERNEL_DIR}
	cp ${DEBIAN_PACKAGE_DIR}/debian/user-mode-linux/usr/bin/linux.uml ${KERNEL_DIR}/netkit-kernel-${SUBARCH}-${KERNEL_NUMBER}-${NETKIT_KERNEL_RELEASE}
	cd ${KERNEL_DIR} ; ln -s netkit-kernel-${SUBARCH}-${KERNEL_NUMBER}-${NETKIT_KERNEL_RELEASE} netkit-kernel
	mkdir -p ${KERNEL_DIR}/modules/
	cp -r ${DEBIAN_PACKAGE_DIR}/debian/user-mode-linux/usr/lib/ ${KERNEL_DIR}/modules/
	echo "Netkit-NG kernel version $(NETKIT_KERNEL_RELEASE)" > ${KERNEL_DIR}/netkit-kernel-version
	cd ${BUILD_DIR}/ ; tar -cvjf ../../${KERNEL_ARCHIVE_FILE} netkit-ng/

