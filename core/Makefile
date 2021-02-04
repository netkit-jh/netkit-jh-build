include ../Makefile.am

# Build parameters
UML_TOOLS_DIR=src/uml-utilities

BIN_DIR=bin
BUILD_DIR=build
NETKIT_BUILD_DIR=$(BUILD_DIR)/netkit-jh
TOOLS_DIR=$(NETKIT_BUILD_DIR)/tools

COPY_FILES=bin setup_scripts man netkit.conf README.mdown LICENSE.txt

.DEFAULT_GOAL := ${NETKIT_BUILD_DIR}

.PHONY: clean
clean:
	cd bin; find . -mindepth 1 -maxdepth 1 -type l -exec unlink {} ";"
	rm -rf $(BUILD_DIR)

.PHONY: mrproper
mrproper: clean
	rm -rf ../${CORE_ARCHIVE_FILE}

.PHONY: archive
archive: ../${CORE_ARCHIVE_FILE}

$(NETKIT_BUILD_DIR)/bin: 
	mkdir -p $(NETKIT_BUILD_DIR)/bin

# Subdirectories to call Make on
SUBDIRS=$(UML_TOOLS_DIR)

# Subdirectory binaries to copy into bin/
SUBDIR_BINS=$(UML_TOOLS_DIR)/tunctl/tunctl $(UML_TOOLS_DIR)/uml_dump/uml_dump \
	$(UML_TOOLS_DIR)/uml_mconsole/uml_mconsole $(UML_TOOLS_DIR)/uml_switch/uml_switch

$(SUBDIR_BINS):
	for dir in $(SUBDIRS); do \
		$(MAKE) -C $$dir; \
	done

submake-install: $(SUBDIR_BINS)
	for bin in $(SUBDIR_BINS); do \
		cp $$bin $(BIN_DIR); \
	done
	
${NETKIT_BUILD_DIR}: $(COPY_FILES) submake-install
	mkdir -p $(TOOLS_DIR)
  
	# Copy relavant files into build directory
	cp -r $(COPY_FILES) $(NETKIT_BUILD_DIR)
  	
  	# Copy tools directory
	cp -r tools/* $(TOOLS_DIR)
	
	# Create symlinks
	(cd $(NETKIT_BUILD_DIR)/bin && ln -sf lstart lrestart; ln -sf lstart ltest && cd -)
	
	# Update version
	echo "Netkit version $(NETKIT_BUILD_RELEASE)" > $(NETKIT_BUILD_DIR)/netkit-version
	
../${CORE_ARCHIVE_FILE}: ${NETKIT_BUILD_DIR}
	tar -C $(BUILD_DIR) --owner=0 --group=0 -cjf ../$(CORE_ARCHIVE_FILE) netkit-jh

