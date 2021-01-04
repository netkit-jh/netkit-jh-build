#!/bin/bash
# Download and install netkit-jh in home directory
# Peter Norris: 22 Nov 2020
# Adapted for Josh Hawking's development to provide an up-to-date kernel

UNZIP_TARGET_DIR="${HOME}/netkit-jh"
DOWNLOAD_DIR="/tmp"
VERSION="VERSION_NUMBER"

# rename target dir if already exists
if [ -d "$UNZIP_TARGET_DIR" ] ; then
	BACKUP_TARGET_DIR="${UNZIP_TARGET_DIR}-$(date '+%F_%H-%M-%S')"
	echo "$UNZIP_TARGET_DIR already exists. Renaming it to $BACKUP_TARGET_DIR so contents are not disturbed."
	mv "$UNZIP_TARGET_DIR" "$BACKUP_TARGET_DIR"
fi

mkdir -p "$UNZIP_TARGET_DIR"
mkdir -p "$DOWNLOAD_DIR"

# CD to download directory to download files
cd "${DOWNLOAD_DIR}"

# download netkit files
# core, kernel and file system from Josh Hawking's updated work
test ! -f release-${VERSION}.sha256 && wget -O release-${VERSION}.sha256 --show-progress "https://github.com/netkit-jh/netkit-jh-build/releases/download/$VERSION/release-$VERSION.sha256" || echo "Found release-${VERSION}.sha256 in ${DOWNLOAD_DIR}, not downloading..."

test ! -f netkit-core-${VERSION}.tar.bz2 && wget -O netkit-core-${VERSION}.tar.bz2 --show-progress "https://github.com/netkit-jh/netkit-jh-build/releases/download/$VERSION/netkit-core-$VERSION.tar.bz2" || echo "Found netkit-core-${VERSION}.tar.bz2 in ${DOWNLOAD_DIR}, not downloading..."
test ! -f netkit-fs-${VERSION}.tar.bz2 && wget -O netkit-fs-${VERSION}.tar.bz2 --show-progress "https://github.com/netkit-jh/netkit-jh-build/releases/download/$VERSION/netkit-fs-$VERSION.tar.bz2" || echo "Found netkit-fs-${VERSION}.tar.bz2 in ${DOWNLOAD_DIR}, not downloading..."
test ! -f netkit-kernel-${VERSION}.tar.bz2 && wget -O netkit-kernel-${VERSION}.tar.bz2 --show-progress "https://github.com/netkit-jh/netkit-jh-build/releases/download/$VERSION/netkit-kernel-$VERSION.tar.bz2" || echo "Found netkit-kernel-${VERSION}.tar.bz2 in ${DOWNLOAD_DIR}, not downloading..."

if ! sha256sum -c release-${VERSION}.sha256; then
    echo "File checksums: FAILED" >&2
    exit 1
fi

echo "File checksums: OK"

echo "Extracting files..."
# strip-components removes the netkit-jh directory
# .tar.bz2
tar -xjvC "$UNZIP_TARGET_DIR" --strip-components=1 -f netkit-core-${VERSION}.tar.bz2
tar -xjvC "$UNZIP_TARGET_DIR" --strip-components=1 -f netkit-fs-${VERSION}.tar.bz2
tar -xjvC "$UNZIP_TARGET_DIR" --strip-components=1 -f netkit-kernel-${VERSION}.tar.bz2

# back up existing bashrc file with date and time as part of filename
BASHBAK="${HOME}/bashrc_$(date "+%F_%H-%M-%S").bak"
cp "${HOME}/.bashrc" "$BASHBAK"

# strip out any lines containing the word "netkit" (case insensitive) from bashrc
grep -iv "netkit" "$BASHBAK" > "${HOME}/.bashrc"

# use heredoc (with tab suppression using the <<- form) to append netkit additions to bashrc  
cat >> "${HOME}/.bashrc" <<-EOF
	# additions for netkit
	export NETKIT_HOME="$UNZIP_TARGET_DIR"
	export MANPATH="\$MANPATH:\$NETKIT_HOME/man"
	export PATH="\$PATH:\$NETKIT_HOME/bin"
EOF

# make (for lab.dep) and net-tools (for tap) needed on ubuntu 18.04
echo "Installing packages to run netkit..."
sudo apt-get update && sudo apt-get install xterm make net-tools wireshark

# check netkit install now works
# TODO: Get this to work... Netkit installs fine, but the check-configurator script doesn't read the environment variables properly so thinks something is wrong
source ~/.bashrc
cd "$UNZIP_TARGET_DIR"

# ./check_configuration.sh
# encourage user to set environment variables for the current bash terminal
echo "Future terminals that you launch will automatically get the netkit settings."
echo "To make the netkit settings available in this terminal, run the following command:"
echo "source ~/.bashrc"

echo "Run source ~/.bashrc, or open a new terminal, and then run ${NETKIT_HOME}/setup_scripts/check_configuration.sh to ensure your Netkit installation works!"

echo -e "\033[1mRun ${UNZIP_TARGET_DIR}/setup_scripts/change_terminal.sh to change your terminal emulator (highly recommended!)\033[0m"
