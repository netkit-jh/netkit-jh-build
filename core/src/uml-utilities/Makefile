TUNCTL = $(shell [ -e /usr/include/linux/if_tun.h ] && echo tunctl)

SUBDIRS = lib mconsole $(TUNCTL) uml_dump uml_switch

CFLAGS = -g -Wall
export CFLAGS

all: 
	set -e ; for dir in $(SUBDIRS); do $(MAKE) -C $$dir $@; done

clean:
	set -e ; for dir in $(SUBDIRS); do $(MAKE) -C $$dir $@; done