include ../Makefile.am

SRC_DIR=src
UML_TOOLS_DIR=$(SRC_DIR)
PATCHES_DIR=$(SRC_DIR)/patches/
BUILD_DIR=build
UML_TOOLS_BUILD_DIR=$(BUILD_DIR)/uml_tools/
NETKIT_BUILD_DIR=$(BUILD_DIR)/netkit-jh/
UML_TOOLS_BIN_DIR=bin/uml_tools/
TOOLS_DIR=$(NETKIT_BUILD_DIR)/tools

FINAL_ARCHIVE="netkit-core-$(NETKIT_BUILD_RELEASE).tar.bz2"


DEBIAN_VERSION=`cat /etc/debian_version | cut -c 1`

.PHONY: default pack

package: build
	mkdir $(NETKIT_BUILD_DIR)
	echo "Netkit version $(NETKIT_BUILD_RELEASE)" > $(NETKIT_BUILD_DIR)/netkit-version
	cp -r bin setup_scripts man netkit.conf README.mdown LICENSE.txt $(NETKIT_BUILD_DIR)
	mkdir -p $(TOOLS_DIR)
	cp -r tools/* $(TOOLS_DIR)
	mkdir  $(NETKIT_BUILD_DIR)$(UML_TOOLS_BIN_DIR)
	cp $(UML_TOOLS_BUILD_DIR)/uml_switch/uml_switch $(NETKIT_BUILD_DIR)$(UML_TOOLS_BIN_DIR)
	cp $(UML_TOOLS_BUILD_DIR)/port-helper/port-helper $(NETKIT_BUILD_DIR)$(UML_TOOLS_BIN_DIR)
	cp $(UML_TOOLS_BUILD_DIR)/tunctl/tunctl $(NETKIT_BUILD_DIR)$(UML_TOOLS_BIN_DIR)
	cp $(UML_TOOLS_BUILD_DIR)/mconsole/uml_mconsole $(NETKIT_BUILD_DIR)$(UML_TOOLS_BIN_DIR)
	cp $(UML_TOOLS_BUILD_DIR)/moo/uml_mkcow $(NETKIT_BUILD_DIR)$(UML_TOOLS_BIN_DIR)
	cp $(UML_TOOLS_BUILD_DIR)/moo/uml_moo $(NETKIT_BUILD_DIR)$(UML_TOOLS_BIN_DIR)
	cp $(UML_TOOLS_BUILD_DIR)/uml_net/uml_net $(NETKIT_BUILD_DIR)$(UML_TOOLS_BIN_DIR)
	cp $(UML_TOOLS_BUILD_DIR)/uml_dump/uml_dump $(NETKIT_BUILD_DIR)$(UML_TOOLS_BIN_DIR)
	
	(cd $(NETKIT_BUILD_DIR)bin &&  ln -s lstart lrestart; ln -s lstart ltest; find uml_tools -mindepth 1 -maxdepth 1 -type f -exec ln -s {} ';' && cd -)
	tar -C $(BUILD_DIR) --owner=0 --group=0 -cjf ../$(CORE_ARCHIVE_FILE) netkit-jh

build: clean
	mkdir $(BUILD_DIR)
	cp -rf $(UML_TOOLS_DIR) $(UML_TOOLS_BUILD_DIR)
	(cd $(UML_TOOLS_BUILD_DIR) && $(MAKE) SIZE_ARCH=$(SIZE_ARCH) && cd -)

clean:
	cd bin; find . -mindepth 1 -maxdepth 1 -type l -exec unlink {} ";"
	rm -rf $(BUILD_DIR)
	rm -f ../$(CORE_ARCHIVE_FILE)

.PHONY: mrproper
mrproper: clean
