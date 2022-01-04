#!/usr/bin/env bash

#     Copyright 2021-2022 Adam Bromiley - Warwick Manufacturing Group,
#     University of Warwick.
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

# This script is part of the Netkit configuration checker. It ensures that
# Netkit is ran with the correct version of Bash.


echo -n ">  Checking Bash version... "


# Ensure the current shell is actually Bash
if [ "${#BASH_VERSINFO[@]}" -eq 0 ]; then
    cat << END_OF_DIALOG
failed.
*** Error: The current shell is not Bash (special variable BASH_VERSINFO is
           unset). The shebang of this, and all other Netkit-JH scripts, is:
              #!/usr/bin/env bash
            
           Ensure that this has not been changed, and that this script is not
           being invoked with a different shell, like:
              some-other-shell "$0"
END_OF_DIALOG
   exit 255
fi


# Get Bash major and minor version number
maj_ver=${BASH_VERSINFO[0]}
min_ver=${BASH_VERSINFO[1]}

if [ "$maj_ver" -eq 4 ] && [ "$min_ver" -lt 4 ] || [ "$maj_ver" -lt 4 ]; then
    # Minimum Bash version to run Netkit-JH is 4.4. This supports associative
    # arrays, the @ parameter expansion operator, and the $! special parameter.
    cat << END_OF_DIALOG
failed.
*** Error: Bash version is too low - it must be version 4.4 or newer. Netkit-JH
           relies on a variety of features ('Bashisms') that improve
           functionality, reliability, and code cleanliness. These features
           mean Netkit-JH is dependent on Bash, and a specific version of Bash.
           To update Bash, run:
              sudo apt --only-upgrade install bash
END_OF_DIALOG
   exit 255
fi


echo "passed."
exit 0
