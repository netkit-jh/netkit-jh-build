include ../Makefile.am

# Build parameters
UML_TOOLS_DIR=src
UML_TOOLS_BUILD_DIR=$(BUILD_DIR)/uml_tools/
UML_TOOLS_BIN_DIR=bin/uml_tools/

BUILD_DIR=build
NETKIT_BUILD_DIR=$(BUILD_DIR)/netkit-jh/
TOOLS_DIR=$(NETKIT_BUILD_DIR)/tools

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

${UML_TOOLS_BUILD_DIR}:
	mkdir $(BUILD_DIR)
	cp -rf $(UML_TOOLS_DIR) $(UML_TOOLS_BUILD_DIR)
	(cd $(UML_TOOLS_BUILD_DIR) && $(MAKE) SIZE_ARCH=$(SIZE_ARCH) && cd -)

${NETKIT_BUILD_DIR}: ${UML_TOOLS_BUILD_DIR}
	mkdir $(NETKIT_BUILD_DIR)
	mkdir -p $(TOOLS_DIR)
  
	# Copy relavant files into build directory
	cp -r bin setup_scripts man netkit.conf README.mdown LICENSE.txt $(NETKIT_BUILD_DIR)
  	
  	# Copy tools directory
	cp -r tools/* $(TOOLS_DIR)
	
	# Copy compiled UML tools in
	mkdir  $(NETKIT_BUILD_DIR)$(UML_TOOLS_BIN_DIR)
	cp $(UML_TOOLS_BUILD_DIR)/uml_switch/uml_switch $(NETKIT_BUILD_DIR)$(UML_TOOLS_BIN_DIR)
	cp $(UML_TOOLS_BUILD_DIR)/port-helper/port-helper $(NETKIT_BUILD_DIR)$(UML_TOOLS_BIN_DIR)
	cp $(UML_TOOLS_BUILD_DIR)/tunctl/tunctl $(NETKIT_BUILD_DIR)$(UML_TOOLS_BIN_DIR)
	cp $(UML_TOOLS_BUILD_DIR)/mconsole/uml_mconsole $(NETKIT_BUILD_DIR)$(UML_TOOLS_BIN_DIR)
	cp $(UML_TOOLS_BUILD_DIR)/moo/uml_mkcow $(NETKIT_BUILD_DIR)$(UML_TOOLS_BIN_DIR)
	cp $(UML_TOOLS_BUILD_DIR)/moo/uml_moo $(NETKIT_BUILD_DIR)$(UML_TOOLS_BIN_DIR)
	cp $(UML_TOOLS_BUILD_DIR)/uml_net/uml_net $(NETKIT_BUILD_DIR)$(UML_TOOLS_BIN_DIR)
	cp $(UML_TOOLS_BUILD_DIR)/uml_dump/uml_dump $(NETKIT_BUILD_DIR)$(UML_TOOLS_BIN_DIR)
	
	# Create symlinks
	(cd $(NETKIT_BUILD_DIR)bin &&  ln -s lstart lrestart; ln -s lstart ltest; find uml_tools -mindepth 1 -maxdepth 1 -type f -exec ln -s {} ';' && cd -)
	
	# Update version
	echo "Netkit version $(NETKIT_BUILD_RELEASE)" > $(NETKIT_BUILD_DIR)/netkit-version
	
../${CORE_ARCHIVE_FILE}: ${NETKIT_BUILD_DIR}
	tar -C $(BUILD_DIR) --owner=0 --group=0 -cjf ../$(CORE_ARCHIVE_FILE) netkit-jh

