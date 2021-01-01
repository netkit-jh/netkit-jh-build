#!/bin/bash
pidof bspwm
if [ $? -eq 0 ] ; then
	echo "Bspwm is running! Downloading and applying patch."
	wget -O ${NETKIT_HOME}/bin/bspwm.patch --show-progress "https://raw.githubusercontent.com/TechSupportJosh/netkit-ng-build/master/patches/bspwm.patch"
	wget -O ${NETKIT_HOME}/bin/szhelper.rb --show-progress "https://raw.githubusercontent.com/TechSupportJosh/netkit-ng-build/master/scripts/szhelper.rb"
	chmod +x ${NETKIT_HOME}/bin/szhelper.rb
	patch -ruN -d ${NETKIT_HOME}/bin -i bspwm.patch
	rm ${NETKIT_HOME}/bspwm.patch
fi
