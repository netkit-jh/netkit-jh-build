MAKEFILE_PATH := $(abspath $(lastword $(MAKEFILE_LIST)))
MAKEFILE_DIR := $(realpath $(dir $(MAKEFILE_PATH)))

include Makefile.am

KERNEL_DIR=kernel
FS_DIR=fs
CORE_DIR=core

INSTALL_LOCATION ?= $(HOME)/netkit-jh

default: build-kernel build-fs build-core

.PHONY: build-kernel
build-kernel: 
	$(MAKE) -C $(KERNEL_DIR)

.PHONY: build-fs
build-fs: 
	$(MAKE) -C $(FS_DIR)

.PHONY: build-core
build-core: 
	$(MAKE) -C $(CORE_DIR)

.PHONY: archives
archives: $(KERNEL_ARCHIVE_FILE) $(FS_ARCHIVE_FILE) $(CORE_ARCHIVE_FILE)

.PHONY: file-hashes
file-hashes: build/release-$(NETKIT_BUILD_RELEASE).sha256

.PHONY: install-script
install-script: build/install-netkit-jh-$(NETKIT_BUILD_RELEASE).sh

build:
	mkdir -p build

.PHONY: release
release: archives file-hashes install-script

$(KERNEL_ARCHIVE_FILE): | build
	$(MAKE) -C $(KERNEL_DIR) archive

$(FS_ARCHIVE_FILE): | build
	$(MAKE) -C $(FS_DIR) archive

$(CORE_ARCHIVE_FILE): | build
	$(MAKE) -C $(CORE_DIR) archive

build/release-$(NETKIT_BUILD_RELEASE).sha256: | build
	cd build; sha256sum *.tar.bz2 > release-$(NETKIT_BUILD_RELEASE).sha256

build/install-netkit-jh-$(NETKIT_BUILD_RELEASE).sh: | build
	cp install-netkit-jh.sh build/install-netkit-jh-$(NETKIT_BUILD_RELEASE).sh
	chmod +x build/install-netkit-jh-$(NETKIT_BUILD_RELEASE).sh
	sed -i "s/VERSION=\"VERSION_NUMBER\"/VERSION=\"$(NETKIT_BUILD_RELEASE)\"/g" build/install-netkit-jh-$(NETKIT_BUILD_RELEASE).sh

.PHONY: clean
clean:
	$(MAKE) -C $(KERNEL_DIR) clean
	$(MAKE) -C $(FS_DIR) clean
	$(MAKE) -C $(CORE_DIR) clean

.PHONY: mrproper
mrproper: clean
	$(MAKE) -C $(KERNEL_DIR) mrproper
	$(MAKE) -C $(FS_DIR) mrproper
	$(MAKE) -C $(CORE_DIR) mrproper
	rm -rf build

.PHONY: install
install: install-script
ifeq ($(shell id -u), 0)
		@echo "Please run 'make install' without root privileges. You will be asked when appropiate to use root privileges."
		exit 1
endif

	@echo "Install location: $(INSTALL_LOCATION)"

	build/install-netkit-jh-$(NETKIT_BUILD_RELEASE).sh --no-download --no-packages --kernel-files=$(MAKEFILE_DIR)/$(KERNEL_DIR)/build/netkit-jh --core-files=$(MAKEFILE_DIR)/$(CORE_DIR)/build/netkit-jh --fs-files=$(MAKEFILE_DIR)/$(FS_DIR)/build/netkit-jh --target-dir="$(INSTALL_LOCATION)"
