#!/usr/bin/env bash

#     Copyright 2021-2022 Adam Bromiley - Warwick Manufacturing Group,
#     University of Warwick.
#     Copyright 2004-2010 Massimo Rimondini - Computer Networks Research Group,
#     Roma Tre University.
#
#     This file is part of Netkit.
# 
#     Netkit is free software: you can redistribute it and/or modify
#     it under the terms of the GNU General Public License as published by
#     the Free Software Foundation, either version 3 of the License, or
#     (at your option) any later version.
# 
#     Netkit is distributed in the hope that it will be useful,
#     but WITHOUT ANY WARRANTY; without even the implied warranty of
#     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#     GNU General Public License for more details.
# 
#     You should have received a copy of the GNU General Public License
#     along with Netkit.  If not, see <http://www.gnu.org/licenses/>.

# This script is part of the Netkit configuration checker. It checks if the
# filesystem Netkit is running from is capable of handling sparse files.


echo -n ">  Checking host filesystem... "


# Non-exhaustive list of filesystems that support sparse files
supportive_fs="ext2?|ext2/ext3|fuse(blk|ctl)|jfs|ntfs|reiserfs|xfs|zfs"

# Get the host filesystem type
fs_type=$(stat --file-system --format "%T" -- "$NETKIT_HOME")

if [[ ! "$fs_type" =~ ^($supportive_fs)$ ]]; then
   cat << END_OF_DIALOG
failed.
*** Warning: Filesystem '$fs_type' may not support sparse files, this could
             result in significant performance loss and increased disk space
             consumption due to larger COW ('.disk') files. It is strongly
             advised to run Netkit on a filesystem that supports sparse files,
             such as ext (any version), NTFS, and XFS.

             It is possible this is a false alarm - the list of supportive
             filesystems cross-referenced is non-exhaustive.
END_OF_DIALOG
   exit 1
fi


echo "passed."
exit 0
