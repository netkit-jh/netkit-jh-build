include ../Makefile.am

BUILD_DIR=build
CACHE_DIR=cache
FINAL_ARCHIVE=../../netkit-filesystem-${SUBARCH}-${NETKIT_FS_RELEASE}.tar.bz2
DEBOOTSTRAP_ARCHIVE=${CACHE_DIR}/debootstrap-cache.tgz

default: ${FINAL_ARCHIVE}

.PHONY: clean
clean:
	rm -rf ${BUILD_DIR}

.PHONY: mrproper
mrproper: clean
	rm -rf ${CACHE_DIR}
	rm -rf ${FINAL_ARCHIVE}

.PHONY: init
init: clean
	mkdir -p ${BUILD_DIR}/netkit/fs

${FINAL_ARCHIVE}: init ${DEBOOTSTRAP_ARCHIVE}
	rootstrap  ${BUILD_DIR}/netkit/fs/netkit-fs-${SUBARCH}-${NETKIT_FS_RELEASE}
	echo "Netkit filesystem version ${NETKIT_FS_RELEASE}" > ${BUILD_DIR}/netkit/fs/netkit-filesystem-version
	cd ${BUILD_DIR}/netkit/fs ; ln -s netkit-fs-${SUBARCH}-${NETKIT_FS_RELEASE} netkit-fs
	cd ${BUILD_DIR}/ ; tar cvjf ${FINAL_ARCHIVE} netkit/

${DEBOOTSTRAP_ARCHIVE}:
	mkdir -p ${BUILD_DIR}/debootstrap/
	mkdir -p ${CACHE_DIR}
	debootstrap --make-tarball=${DEBOOTSTRAP_ARCHIVE} wheezy ${BUILD_DIR}/debootstrap/ http://ftp.fr.debian.org/debian
