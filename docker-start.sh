#!/usr/bin/env bash

RED='\033[0;31m'
GREEN='\033[0;32m'
MAG='\033[0;35m'
LMAG='\033[0;95m'
WH='\033[0;97m'
CY='\033[0;36m'
LG='\033[0;92m'
RST='\033[0m'

[[ -n $(mount -l -t proc) ]] && \
    echo -e "\n/proc already mounted ${GREEN}[✓]"${RST} || \
    mount -t proc proc /proc

[[ -n $(mount -l -t proc) ]] || {
    echo -e "\n${RED}Could not mount /proc. Exitting.${RST}" \
    && exit 1
}

mount | grep '/netkit-build' &> /dev/null && \
    echo -e "\n/netkit-build mounted ${GREEN}[✓]${RST}" || {
    echo -e "\n${RED}Source Code Dir not mounted. ${RST}
Remember to pass a volume in the docker argument with \`-v PATH_TO_NETKIT_JH_BUILD:/netkit-build\`

${MAG}https://netkit-jh.github.io/docs/dev/guides/dockerbuild/${RST}

Exitting.\n" \
    && exit 1
}

# Should already be in /netkit-build from WORKDIR in Dockerfile
if [ -f "Makefile" ]; then
    echo -e "\nAttempting to run make with args ${MAKE_ARGS}\n"
    make ${MAKE_ARGS} && \
        echo -e "\nMake exitted successfully.${GREEN}[✓]${RST}\n" ||
        echo -e "\n${RED}Error running make.${RST}\n"
else
    echo -e "\n${RED}Makefile doesn't exist.${RST}

Have you cloned the netkit-jh-build source? Please check you are passing the correct directory as a docker volume. You may need to give a full path.

${MAG}https://netkit-jh.github.io/docs/dev/guides/dockerbuild/${RST}

Exitting.\n"
    exit 1
fi
