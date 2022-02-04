#!/usr/bin/env bash

#     Copyright 2021-2022 Adam Bromiley. Joshua Hawking - Warwick Manufacturing
#     Group, University of Warwick.
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


###############################################################################
# Wait for all files to exist before returning.
# Usage:
#   print_vhost_summary TIMEOUT [FILE]...
# Arguments:
#   $1 - timeout in seconds to wait before returning an error if not all files
#        exist.
#  ... - list of files to check for
# Returns:
#   0 if all files exist before the timeout, non-zero otherwise
###############################################################################
wait_for_files() {
   local timeout=$1
   local files=( "${@:2}" )

   for ((i = timeout - 1; i >= 0; --i)); do
      echo -en "\033[0K\rWaiting for files (${timeout}s)"

      for file in "${files[@]}"; do
         if [ ! -f "$file" ]; then
            sleep 1
            continue
         fi
      done

      # Return success if all files exist
      echo
      return 0
   done

   echo
   return 1
}


# Script exits with 1 if any lab test fails
test_return=0


# Define relevant directories
tests_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" > /dev/null 2>&1 && pwd)
configs_dir="$tests_dir/configs/"
labs_dir="$tests_dir/labs/"

test_results_file="$tests_dir/test_results.txt"


cat << END_OF_DIALOG | tee -- "$test_results_file"
Test started at $(date)

Build information:
$(vstart --version)

END_OF_DIALOG


# Firstly, start off with vclean to remove any running processes or files that
# might affect the tests.
echo "Initialising test: cleaning install (raised privileges necessary)"
vclean --clean-all > /dev/null


for config_file in "$configs_dir"/*; do
   unset config
   declare -A config

   # Get test configuration
   while IFS= read -r configuration; do
      opt=${configuration%%=*}
      config[$opt]=${configuration#*=}
   done < <(grep -- "=" "$config_file")

   echo "--- Starting test '${config[NAME]}' ---"

   lab_dir="$labs_dir/${config[LAB_FOLDER]}/"

   # Validate lab directory
   if [ ! -d "$lab_dir" ]; then
      echo "${config[NAME]}: Failed (lab folder does not exist)" |
         tee --append -- "$test_results_file" 2>&1
      test_return=1
      continue
   fi

   IFS="," read -ra success_filenames <<< "${config[FILES]}"

   # Prepend lab directory to each filename
   success_files=( "${success_filenames[@]/#/$lab_dir}" )

   # Remove any leftover expected files
   rm --force -- "${success_files[@]}"

   lstart_cmd=( "lstart" "-d" "$lab_dir" )
   [ -n "${config[TERMINAL]}" ] && lstart_cmd+=( "--pass=--xterm=${config[TERMINAL]}" )

   # Clean then run the lab with a timeout
   lclean -d "$lab_dir" > /dev/null

   time_started=$(date +%s)
   timeout -- "${config[LAB_TIMEOUT]}" "${lstart_cmd[@]}" > /dev/null
   ret=$?

   if [ "$ret" -eq 124 ]; then
      # If timeout returns 124, then the command has timed out
      echo "${config[NAME]}: Failed (lab failed to start after ${config[LAB_TIMEOUT]} seconds)" |
         tee --append -- "$test_results_file" 1>&2
      test_return=1
   elif [ "$ret" -ne 0 ]; then
      echo "${config[NAME]}: Failed (lab failed to start for an unknown reason)" |
         tee --append -- "$test_results_file" 1>&2
      test_return=1
   else
      if wait_for_files "${config[TIMEOUT]}" "${success_files[@]}"; then
         duration=$(( $(date +%s) - time_started ))
         echo "${config[NAME]}: Success (completed in $duration seconds)" |
            tee --append -- "$test_results_file"
      else
         echo "${config[NAME]}: Failed (success files not found after ${config[TIMEOUT]} seconds)" |
            tee --append -- "$test_results_file" 1>&2
         test_return=1
      fi
   fi

   # Crash and clean the lab
   lcrash -d "$lab_dir" > /dev/null
   lclean -d "$lab_dir" > /dev/null

   # Now remove any expected files in order to create a clean slate
   rm --force -- "${success_files[@]}"
done


echo "Completing test: cleaning install (raised privileges necessary)"
vclean --clean-all > /dev/null


echo -e "\nTest finished at $(date)" | tee --append -- "$test_results_file"


exit "$test_return"
