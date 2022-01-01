include ../Makefile.am

# Build parameters
UML_TOOLS_DIR=src/uml-utilities

# Subdirectories to call Make on
SUBDIRS=$(UML_TOOLS_DIR)

BIN_DIR=bin
BUILD_DIR=build
NETKIT_BUILD_DIR=$(BUILD_DIR)/netkit-jh
TOOLS_DIR=$(NETKIT_BUILD_DIR)/tools

COPY_FILES=bash-completion bin setup_scripts man netkit.conf \
	netkit.conf.default README.mdown LICENSE.txt

.DEFAULT_GOAL := $(NETKIT_BUILD_DIR)

.PHONY: clean clean-subdirs
clean-subdirs:
	for dir in $(SUBDIRS); do \
		$(MAKE) -C $$dir clean; \
	done
clean: clean-subdirs
	cd bin; find . -mindepth 1 -maxdepth 1 -type l -exec unlink {} ";"
	rm -rf $(BUILD_DIR)

.PHONY: mrproper
mrproper: clean
	rm -rf ../$(CORE_ARCHIVE_FILE)

.PHONY: archive
archive: ../$(CORE_ARCHIVE_FILE)

$(NETKIT_BUILD_DIR)/bin: 
	mkdir -p $(NETKIT_BUILD_DIR)/bin

# Subdirectory binaries to copy into bin/
SUBDIR_BINS=$(UML_TOOLS_DIR)/tunctl/tunctl $(UML_TOOLS_DIR)/uml_dump/uml_dump \
	$(UML_TOOLS_DIR)/uml_mconsole/uml_mconsole $(UML_TOOLS_DIR)/uml_switch/uml_switch

$(SUBDIR_BINS):
	for dir in $(SUBDIRS); do \
		$(MAKE) -C $$dir; \
	done

$(NETKIT_BUILD_DIR): $(COPY_FILES) $(SUBDIR_BINS)
	mkdir -p $(TOOLS_DIR)
  
	# Copy relavant files into build directory
	cp -r $(COPY_FILES) $(NETKIT_BUILD_DIR)

	# Copy tools directory
	cp -r tools/* $(TOOLS_DIR)

	# Move UML Utilities (we don't want to copy because it dirties core/bin)
	for bin in $(SUBDIR_BINS); do \
		mv $$bin $(NETKIT_BUILD_DIR)/bin; \
	done

	# Again, to prevent dirtying core/src
	for dir in $(SUBDIRS); do \
		$(MAKE) -C $$dir clean; \
	done

	# Create symlinks
	(cd $(NETKIT_BUILD_DIR)/bin && ln -sf lstart ltest && cd -)

	# Update version
	echo "Netkit version $(NETKIT_BUILD_RELEASE)" > $(NETKIT_BUILD_DIR)/netkit-version

../$(CORE_ARCHIVE_FILE): $(NETKIT_BUILD_DIR)
	tar -C $(BUILD_DIR) --owner=0 --group=0 -cjf ../$(CORE_ARCHIVE_FILE) netkit-jh
