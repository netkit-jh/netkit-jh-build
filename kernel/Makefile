BUILD_DIR=../build
KERNEL_VERSION=user-mode-linux-3.2-2um

kernel:
	cd ${BUILD_DIR} ; apt-get source user-mode-linux
	cd ${BUILD_DIR} ; apt-get build-dep user-mode-linux
	cp config.i386 ${BUILD_DIR}/${KERNEL_VERSION}/	
	cp patches/* ${BUILD_DIR}/${KERNEL_VERSION}/debian/patches/
	cd ${BUILD_DIR}/${KERNEL_VERSION}/ ; dpkg-buildpackage -rfakeroot -nc -uc

