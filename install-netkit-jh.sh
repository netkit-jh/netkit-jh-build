#!/usr/bin/env bash

# Download and install netkit-jh in home directory
# Modified from Peter Norris' original install script

#
# Users experiencing issues during the installation process
# should be able to report back with the exact command that
# has failed.
#
set -e

# Default variables
VERSION="VERSION_NUMBER"
TARGET_INSTALL_DIR="${HOME}/netkit-jh"
BACKUP_INSTALL_DIR="${HOME}/netkit-jh-$(date '+%F_%H-%M-%S')"
INSTALL_APT_PACKAGES=true
DOWNLOAD_FILES=true
DOWNLOAD_DIR="/tmp"
DOWNLOAD_URL_PREFIX="https://github.com/netkit-jh/netkit-jh-build/releases/download/$VERSION/"

# Start and end delimeters for Netkit-related stuff in the shell's rc file
NK_RC_HEADER="#=== NETKIT VARIABLES ==="
NK_RC_FOOTER="#=== NETKIT VARIABLES END ==="

# Environment variables required for Netkit-JH to run
NK_ENV_VARS="
export NETKIT_HOME=\"${TARGET_INSTALL_DIR}\"
export MANPATH=\"\$MANPATH:\$NETKIT_HOME/man\"
export PATH=\"\$PATH:\$NETKIT_HOME/bin\""

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

    # Temporarily disable error checking as this function will return a non-zero code, causing bash to stop running the script
    set +e
    check_files_exist "${DOWNLOAD_DIR}" "${files_expected[@]}"
    files_exist=$?
    set -e

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
    if [ -z "$(grep "$NK_RC_HEADER" "${RC_FILE}")" ]; then
        # strip out any lines containing the word "netkit" (case insensitive) from bashrc
        grep -iv "netkit" "${BAK_FILE}" > "${RC_FILE}"
    else
        # Otherwise, just wipe between the headers
        sed -i "/^$NK_RC_HEADER/,/^$NK_RC_FOOTER/d;" ${RC_FILE}
    fi

    echo "$NK_RC_HEADER" >> "${RC_FILE}"

    # Append Netkit additions to bashrc
    echo "$NK_ENV_VARS" >> "${RC_FILE}"

    # Source the Bash completion script
    # shellcheck disable=SC2016
    [ "$(basename -- "$RC_FILE")" = ".bashrc" ] && echo '. "$NETKIT_HOME/bin/netkit_bash_completion"' >> "${RC_FILE}"

    echo "$NK_RC_FOOTER"
done

# make (processing lab.dep)
# net-tools (manage_tuntap)
# coreutils (sha256sum and stdbuf)
if [ "${INSTALL_APT_PACKAGES}" = true ]; then
    echo "Installing packages to run netkit..."
    sudo apt-get update && sudo apt-get install xterm make net-tools curl coreutils
fi

# Restore config + handle updating config
if [ "${PREVIOUS_INSTALL_FOUND}" = true ]; then
    echo ""
    echo "Restoring configuration from previous installation."
    ${TARGET_INSTALL_DIR}/setup_scripts/handle_config.sh "${BACKUP_INSTALL_DIR}" "${TARGET_INSTALL_DIR}"
fi

echo "Netkit-JH should now be installed. Checking configuration..."

# Ubuntu (and similar) distributions prevent .bashrc from running in a
# non-interactive shell. So here we can just evaluate the environment variables
# export commands
eval "$NK_ENV_VARS"

cd "${TARGET_INSTALL_DIR}/setup_scripts"
./check_configuration.sh || exit 1

# Encourage user to set environment variables for the current terminal
echo ""
echo "To use Netkit-JH now, open a new terminal window or run source ~/.bashrc (or .zshrc if using Zsh)"

echo ""
echo -e "\033[1mRun ${TARGET_INSTALL_DIR}/setup_scripts/change_terminal.sh to change your terminal emulator (highly recommended!)\033[0m"
