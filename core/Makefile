include ../Makefile.am

# Build parameters
UML_TOOLS_DIR=src
UML_TOOLS_BUILD_DIR=$(BUILD_DIR)/uml_tools/
UML_TOOLS_BIN_DIR=bin/uml_tools/

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
	
$(NETKIT_BUILD_DIR)/bin/uml_dump: src/uml_dump/uml_dump.c | $(NETKIT_BUILD_DIR)/bin
	$(CC) -g -Wall -o $(NETKIT_BUILD_DIR)/bin/uml_dump src/uml_dump/uml_dump.c
	
${NETKIT_BUILD_DIR}: $(COPY_FILES) $(NETKIT_BUILD_DIR)/bin/uml_dump
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

