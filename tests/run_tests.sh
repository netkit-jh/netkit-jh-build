#!/bin/bash

# Returns 1 if the files existed, or 0 if they didn't after waiting for wait_seconds (first parameter)
wait_for_files() {
    local wait_seconds="$1"; shift
    local files=("$@")

    while test $((wait_seconds--)) -gt 0; do
        echo -ne "Waiting for files (${wait_seconds}s) \033[0K\r"

        failed=0
        for file in "${files[@]}"; do
            if [ ! -f ${file} ]; then
                failed=1
                # echo "${file} does not exist"
            fi
        done

        # If all files have existed, return 1 (success)
        if [ ${failed} -eq 0 ]; then
            return 1
        fi
        
        sleep 1
    done

    # Otherwise, return 0 (failed)
    return 0
}

# Firstly, start off with a vclean to remove any hanging machines
vclean --clean-all

# CD into script directory
cd "${0%/*}"
tests_directory="$(pwd)"
configs_directory="${tests_directory}/configs"
labs_directory="${tests_directory}/labs"

output_file="${tests_directory}/test_results.txt"

echo -e "Test started at $(date)\n\nBuild information:" > ${output_file}
echo -e "$(vstart --version)\n" >> ${output_file}

# Process configs
cd ${configs_directory}

for config_file in *; do
    # Define a config dictionary
    declare -A config

    while read line; do
        if echo $line | grep -F = &>/dev/null
        then
            varname=$(echo "$line" | cut -d '=' -f 1)
            config[$varname]=$(echo "$line" | cut -d '=' -f 2-)
        fi
    done < ${config_file}

    echo "Starting test: ${config[NAME]}"

    # Validate lab directory
    if [ ! -d "${labs_directory}/${config[LAB_FOLDER]}" ]; then
        echo "Lab folder '${config[LAB_FOLDER]}' does not exist for ${config[NAME]} (${config_file}), skipping test."
        echo -e "${config[NAME]}: Failed (lab folder does not exist)" >> ${output_file}
        continue
    fi

    # Create a list of expected expected_file_names
    IFS=',' read -r -a expected_file_names <<< "${config[FILES]}"

    # Add lab directory to start of each file name
    expected_files=("${expected_file_names[@]/#/${labs_directory}/${config[LAB_FOLDER]}/}")

    # CD into lab directory
    cd ${labs_directory}/${config[LAB_FOLDER]}

    # Remove any leftover expected files
    rm -f "${expected_files[@]}"

    time_started=$(date +%s)

    lab_arguments=""

    # Check if a terminal is specified, if so, configure lab arguments
    if [ -v config[TERMINAL] ]; then
        lab_arguments="${lab_arguments} --pass=--xterm=${config[TERMINAL]}"
    fi

    # Run the lab
    lclean
    timeout ${config[LAB_TIMEOUT]} lstart ${lab_arguments}

    # If timeout returns 124, then the command has timed out
    if [ $? -eq 124 ]; then
        echo "lstart failed to complete, test failed."
        echo -e "${config[NAME]}: Failed (lab failed to start after ${config[LAB_TIMEOUT]} seconds)" >> ${output_file}
    else

        wait_for_files ${config[FILES_TIMEOUT]} "${expected_files[@]}"
        files_exist=$?

        # Wait for files
        if [ ${files_exist} -eq 1 ]; then
            echo "All files found, test successful."
            echo -e "${config[NAME]}: Successful (completed in $(expr $(date +%s) - ${time_started}) seconds)" >> ${output_file}
        else
            echo "Files were not found after timeout, test failed."
            echo -e "${config[NAME]}: Failed (test files were not found after ${config[FILES_TIMEOUT]} seconds)" >> ${output_file}
        fi

    fi

    # Crash and clean the lab
    lcrash
    lclean

    # Now remove any expected files in order to create a clean slate
    rm -f "${expected_files[@]}"

    # And return to the configs directory to process the next test
    cd ${configs_directory}
done

echo -e "\nTest finished at $(date)" >> ${output_file}
