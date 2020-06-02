#!/bin/bash

# Check if the first arg is an option (starts with -)
first_option=$(echo $1 | grep -Ec "^-")

if [[ $# -eq 0 ]] || [[ first_option -eq 1 ]]; then
    # Run Jupyter Lab with default settings
    jupyter lab $@
else
    # Checks if suffix is .py or .sh for the first argument
    suffix_py=$(echo $1 | grep -Ec ".*\.py$")
    suffix_sh=$(echo $1 | grep -Ec ".*\.sh$")
    echo "$suffix_py $1"
    # If .py, execute python script with args
    if [[ $suffix_py -eq 1 ]]; then
        python $@
    # If .sh, execute the shell script with args
    elif [[ $suffix_sh -eq 1 ]]; then
        $@
    fi
fi