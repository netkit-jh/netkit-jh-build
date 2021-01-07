#!/bin/bash

# This script is responsible for copying over the previous user's installation and updating the config with any new options.

BACKUP_DIR="$1"
NEW_DIR="$2"

if [ ! -f ${BACKUP_DIR}/netkit.conf ]; then
	echo "No previous netkit.conf found in ${BACKUP_DIR}, exiting."
	exit 1
fi

# Firstly copy over the previous config 
cp ${BACKUP_DIR}/netkit.conf ${NEW_DIR}/netkit.conf

# Then check whether this config already has a CONFIG_VERSION setting
# For Netkit-JH versions 1.0.0 and below, this is not defined so it will need to be added
if [ -z "$(grep "CONFIG_VERSION" ${NEW_DIR}/netkit.conf)" ]; then
	sed -i "s/# Warning: none of the following parameters can include spaces in its value./# Warning: none of the following parameters can include spaces in its value.\n\nCONFIG_VERSION=1/g" ${NEW_DIR}/netkit.conf
fi

# Note that Netkit configuration versions are independant to release versions. They are incremental (i.e V1 -> V2 -> V3 -> V4).
# This script should be updated whenever new configurations are added.

CURRENT_VERSION=$(grep "CONFIG_VERSION" ${NEW_DIR}/netkit.conf | sed "s/CONFIG_VERSION=//g")

# Upgrade from v1 to v2
# This upgrade can be used as a template for new upgrades.
# - Ensures CONFIG_VERSION has been defined. Any config without CONFIG_VERSION is considered V1.
if [ "${CURRENT_VERSION}" -lt 2 ]; then
	echo "Upgrading Netkit configuration to V2."

	# Here, we can do anything else we'd want to do, for example, appending new options.
	
	# Finally, update the version.
	CURRENT_VERSION=2
	sed -i "s/CONFIG_VERSION=1/CONFIG_VERSION=2/g" ${NEW_DIR}/netkit.conf
fi

# Upgrade from v2 to v3
# - Add TMUX options
# - Sets mconsole dir to machines
if [ "${CURRENT_VERSION}" -lt 3 ]; then
    echo "Upgrading Netkit configuration to V3."

    
    echo "
# TMUX Configuration
USE_TMUX=FALSE                  # Run the vm inside a tmux session on the host
                                # this means you can then connect and disconnect from it 
                                # when you want (using the vconnect command) and send
                                # commands to it with vcommand.
TMUX_OPEN_TERMS=FALSE           # Open a terminal with the tmux session for the machine
                                # this will run vconnect in the background to attempt to 
                                # connect. N.b. this has a timeout - if the tmux session
                                # fails to open this will eventually stop polling it.
                                # This option only takes effect when USE_TMUX is true
CHECK_FOR_UPDATES=yes           # When running lstart, a request will be sent to
                                # Github to check for a new release of Netkit-JH.
                                # This check will only be made every
                                # UPDATE_CHECK_PERIOD days. 
UPDATE_CHECK_PERIOD=5           # How long to wait between checking for new releases.
    " >> ${NEW_DIR}/netkit.conf

	sed -i "s/MCONSOLE_DIR=\".*\"/MCONSOLE_DIR=\"$HOME/.netkit/machines\"/g" ${NEW_DIR}/netkit.conf
	
    # Finally, update the version.
    CURRENT_VERSION=3
    sed -i "s/CONFIG_VERSION=2/CONFIG_VERSION=3/g" ${NEW_DIR}/netkit.conf
fi
