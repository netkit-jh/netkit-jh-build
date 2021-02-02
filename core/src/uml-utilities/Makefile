TUNCTL = $(shell [ -e /usr/include/linux/if_tun.h ] && echo tunctl)

SUBDIRS = lib jail jailtest humfsify mconsole moo port-helper $(TUNCTL) \
	uml_net uml_switch watchdog umlfs
UMLVER = $(shell date +%Y%m%d)
TARBALL = uml_utilities_$(UMLVER).tar.bz2
BIN_DIR = /usr/bin
LIB_DIR = /usr/lib/uml

CFLAGS = -g -Wall
#CFLAGS = -g -O2 -Wall

export BIN_DIR LIB_DIR CFLAGS

all install: 
	set -e ; for dir in $(SUBDIRS); do $(MAKE) -C $$dir $@; done

tarball : clean spec
	cd .. ;					\
	mv tools tools-$(UMLVER);		\
	tar cjf $(TARBALL) tools-$(UMLVER);	\
	mv tools-$(UMLVER) tools

clean:
	rm -rf *~
	set -e ; for dir in $(SUBDIRS); do $(MAKE) -C $$dir $@; done

spec:	
	sed -e 's/__UMLVER__/$(UMLVER)/' < uml_util.spec.in > uml_util.spec
