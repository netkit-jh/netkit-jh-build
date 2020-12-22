include ../Makefile.am

KERNEL_VERSION=user-mode-linux-5.9um1
KERNEL_NUMBER=5.9

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
	chown _apt ${BUILD_DIR}
	cd ${BUILD_DIR} ; apt-get -yq source user-mode-linux
	cd ${BUILD_DIR} ; apt-get -yq build-dep user-mode-linux
	chown root ${BUILD_DIR}

${DEBIAN_PACKAGE_DIR}/debian/user-mode-linux/usr/bin/linux.uml: ${DEBIAN_PACKAGE_DIR}
	cp patches/* ${DEBIAN_PACKAGE_DIR}/debian/patches/
	# Copy in our kernel config
	cp config.amd64 ${BUILD_DIR}/${KERNEL_VERSION}/config.amd64
	cd ${DEBIAN_PACKAGE_DIR} ; dpkg-buildpackage -rfakeroot -nc -uc -d

../${KERNEL_ARCHIVE_FILE}: ${DEBIAN_PACKAGE_DIR}/debian/user-mode-linux/usr/bin/linux.uml
	mkdir -p ${KERNEL_DIR}
	cp ${DEBIAN_PACKAGE_DIR}/debian/user-mode-linux/usr/bin/linux.uml ${KERNEL_DIR}/netkit-kernel-${KERNEL_NUMBER}
	cd ${KERNEL_DIR} ; ln -s netkit-kernel-${KERNEL_NUMBER} netkit-kernel
	mkdir -p ${KERNEL_DIR}/modules/
	cp -r ${DEBIAN_PACKAGE_DIR}/debian/user-mode-linux/usr/lib/ ${KERNEL_DIR}/modules/
	echo "Netkit-NG UML version $(KERNEL_VERSION)" > ${KERNEL_DIR}/netkit-kernel-version
	cd ${BUILD_DIR}/ ; tar -cvjf ../../${KERNEL_ARCHIVE_FILE} netkit-ng/

