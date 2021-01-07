#!/bin/bash

# Download and install netkit-jh in home directory
# Modified from Peter Norris' original install script

# Default variables
VERSION="VERSION_NUMBER"
TARGET_INSTALL_DIR="${HOME}/netkit-jh"
BACKUP_INSTALL_DIR="${HOME}/netkit-jh-$(date '+%F_%H-%M-%S')"
INSTALL_APT_PACKAGES=true
DOWNLOAD_FILES=true
DOWNLOAD_DIR="/tmp"
DOWNLOAD_URL_PREFIX="https://github.com/netkit-jh/netkit-jh-build/releases/download/$VERSION/"

# If desired, you can specify a directory where the files have already been 
# extracted (primarily for development purposes)
KERNEL_EXTRACTED_FILES=""
FS_EXTRACTED_FILES=""
CORE_EXTRACTED_FILES="" 

# Process arguments
for i in "$@"
do
case $i in
    --target-dir=*)
    TARGET_INSTALL_DIR="${i#*=}"
    shift # past argument=value
    ;;
    --backup-dir=*)
    BACKUP_INSTALL_DIR="${i#*=}"
    shift # past argument=value
    ;;
    --no-packages)
    INSTALL_APT_PACKAGES=false
    shift # past argument=value
    ;;
    --no-packages)
    DOWNLOAD_FILES=false
    shift # past argument=value
    ;;
    --download-url=*)
    DOWNLOAD_URL_PREFIX="${i#*=}"
    shift # past argument=value
    ;;
    --download-dir=*)
    DOWNLOAD_DIR="${i#*=}"
    shift # past argument=value
    ;;
    --kernel-files=*)
    KERNEL_EXTRACTED_FILES="${i#*=}"
    shift # past argument=value
    ;;
    --fs-files=*)
    FS_EXTRACTED_FILES="${i#*=}"
    shift # past argument=value
    ;;
    --core-files=*)
    CORE_EXTRACTED_FILES="${i#*=}"
    shift # past argument=value
    ;;
    -h|--help)
    echo "Netkit-JH Installation script
usage: install-netkit-jh-${VERSION}.sh [arguments]

Available arguments:
--target-dir            : Absolute path to a folder to install Netkit to.
--backup-dir            : Absolute path to where the previous installation of Netkit should be moved to.
--no-packages           : Do not download packages required to run Netkit from apt.
--no-download           : Do not download kernel/fs/core files if they are not found inside download-dir.
--download-url          : Specify the URL prefix to download the files from.
--download-dir          : Path to where the files are downloaded to.
--kernel-files          : Absolute path to where the kernel files have been extracted. This path should
                          point to the netkit-jh folder within the extracted archive.
--fs-files              : Absolute path to where the filesystem files have been extracted. This path should
                          point to the netkit-jh folder within the extracted archive.
--core-files            : Absolute path to where the core files have been extracted. This path should point
                          to the netkit-jh folder within the extracted archive.

"
    exit 0
    ;;
    *)
          # unknown option
    ;;
esac
done

# Runtime variables
PREVIOUS_INSTALL_FOUND=false # Was a previous installation found and backed up?

# Takes in a directory and array of file names and returns 0 if all were found, else 1 if any of them weren't failed
check_files_exist() 
{
	DIRECTORY="$1"
	shift;
	FILES=("$@")
	
	FAILED=0
	
	for FILE in "${FILES[@]}"; do
		if [ ! -f "${DIRECTORY}/${FILE}" ]; then
			echo "Cannot find file ${DIRECTORY}/${FILE}."
			FAILED=1
		fi
	done
	
	return ${FAILED}
}

# Rename target dir if already exists
if [ -d "${TARGET_INSTALL_DIR}" ] ; then
	echo "${TARGET_INSTALL_DIR} already exists. Renaming it to ${BACKUP_INSTALL_DIR} so contents are not disturbed."
	mv "${TARGET_INSTALL_DIR}" "${BACKUP_INSTALL_DIR}"
	PREVIOUS_INSTALL_FOUND=true
fi

mkdir -p "${TARGET_INSTALL_DIR}"

# Check whether they've specified extracted files
if [ -n "${KERNEL_EXTRACTED_FILES}" -a -n "${FS_EXTRACTED_FILES}" -a -n "${CORE_EXTRACTED_FILES}" ]; then
	cp -r "${KERNEL_EXTRACTED_FILES}/." "${TARGET_INSTALL_DIR}"
	cp -r "${FS_EXTRACTED_FILES}/." "${TARGET_INSTALL_DIR}"
	cp -r "${CORE_EXTRACTED_FILES}/." "${TARGET_INSTALL_DIR}"
else
	files_expected=("release-${VERSION}.sha256" "netkit-core-${VERSION}.tar.bz2" "netkit-fs-${VERSION}.tar.bz2" "netkit-kernel-${VERSION}.tar.bz2")
	check_files_exist "${DOWNLOAD_DIR}" "${files_expected[@]}"
	files_exist=$?
	
	if [ ${files_exist} -eq 0 ]; then
		# If all expected files are found, we can continue
		echo "Downloaded files found in ${DOWNLOAD_DIR}, continuing..."
	else
		# Otherwise, we can download the files
		if [ "${DOWNLOAD_FILES}" = "true" ]; then
			mkdir -p "${DOWNLOAD_DIR}"

			wget -O "${DOWNLOAD_DIR}/release-${VERSION}.sha256" --show-progress "${DOWNLOAD_URL_PREFIX}/release-${VERSION}.sha256"
			wget -O "${DOWNLOAD_DIR}/netkit-core-${VERSION}.tar.bz2" --show-progress "${DOWNLOAD_URL_PREFIX}/netkit-core-${VERSION}.tar.bz2"
			wget -O "${DOWNLOAD_DIR}/netkit-fs-${VERSION}.tar.bz2" --show-progress "${DOWNLOAD_URL_PREFIX}/netkit-fs-${VERSION}.tar.bz2"
			wget -O "${DOWNLOAD_DIR}/netkit-kernel-${VERSION}.tar.bz2" --show-progress "${DOWNLOAD_URL_PREFIX}/netkit-kernel-${VERSION}.tar.bz2"
		else
			echo "The files above were not found and downloading is disabled, exiting installation."
			exit 1
		fi
	fi
	
	(cd ${DOWNLOAD_DIR}; sha256sum -c release-${VERSION}.sha256)
	FILES_INVALID=$?
	
	if [ ${FILES_INVALID} -eq 1 ]; then
		echo "File checksums failed to verify, please delete the downloaded files and re-run this script." >&2
		exit 1
	fi
	
	# strip-components removes the netkit-jh directory
	tar -xjvC "${TARGET_INSTALL_DIR}" --strip-components=1 -f ${DOWNLOAD_DIR}/netkit-core-${VERSION}.tar.bz2
	tar -xjvC "${TARGET_INSTALL_DIR}" --strip-components=1 -f ${DOWNLOAD_DIR}/netkit-fs-${VERSION}.tar.bz2
	tar -xjvC "${TARGET_INSTALL_DIR}" --strip-components=1 -f ${DOWNLOAD_DIR}/netkit-kernel-${VERSION}.tar.bz2
fi

RC_FILES=("${HOME}/.bashrc" "${HOME}/.zshrc")
for RC_FILE in "${RC_FILES[@]}"; do
	# Check whether this file exists
	if [ ! -f ${RC_FILE} ]; then
		continue
	fi
	
	# Backup existing file with date and time as part of filename
	BAK_FILE="${RC_FILE}_$(date "+%F_%H-%M-%S").bak"
	cp "${RC_FILE}" "${BAK_FILE}"

	# Check whether the netkit variables header exists, if not, wipe all cases of netkit
	if [ -z "$(grep "=== NETKIT VARIABLES ===" "${RC_FILE}")" ]; then
		# strip out any lines containing the word "netkit" (case insensitive) from bashrc
		grep -iv "netkit" "${BAK_FILE}" > "${RC_FILE}"
	else
		# Otherwise, just wipe between the headers
		sed -i "/^#=== NETKIT VARIABLES ===/,/^#=== NETKIT VARIABLES END ===/d;" ${RC_FILE}
	fi

	# use heredoc (with tab suppression using the <<- form) to append netkit additions to bashrc  
	cat >> "${RC_FILE}" <<-EOF
	#=== NETKIT VARIABLES ===
		# additions for netkit
		export NETKIT_HOME="${TARGET_INSTALL_DIR}"
		export MANPATH="\$MANPATH:\$NETKIT_HOME/man"
		export PATH="\$PATH:\$NETKIT_HOME/bin"
	#=== NETKIT VARIABLES END ===
	EOF

done

# make (for lab.dep) and net-tools (for tap) needed on ubuntu 18.04
if [ "${INSTALL_APT_PACKAGES}" = true ]; then
	echo "Installing packages to run netkit..."
	sudo apt-get update && sudo apt-get install xterm make net-tools uml-utilities
fi

# Restore config + handle updating config
if [ "${PREVIOUS_INSTALL_FOUND}" = true ]; then
	echo ""
	echo "Restoring configuration from previous installation."
	${TARGET_INSTALL_DIR}/setup_scripts/handle_config.sh "${BACKUP_INSTALL_DIR}" "${TARGET_INSTALL_DIR}"
fi 

# check netkit install now works
# TODO: Get this to work... Netkit installs fine, but the check-configurator script doesn't read the environment variables properly so thinks something is wrong
source ~/.bashrc
cd "${TARGET_INSTALL_DIR}"

# ./check_configuration.sh
# encourage user to set environment variables for the current bash terminal
echo "" 
echo "Future terminals that you launch will automatically get the netkit settings."
echo "To make the netkit settings available in this terminal, run the following command:"
echo "source ~/.bashrc"

echo ""
echo "Run source ~/.bashrc, or open a new terminal, and then run ${NETKIT_HOME}/setup_scripts/check_configuration.sh to ensure your Netkit installation works!"

echo ""
echo -e "\033[1mRun ${TARGET_INSTALL_DIR}/setup_scripts/change_terminal.sh to change your terminal emulator (highly recommended!)\033[0m"
