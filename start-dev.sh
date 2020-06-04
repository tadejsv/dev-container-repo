#!/bin/bash

# Check if the first arg is an option (starts with -)
first_option=$(echo $1 | grep -Ec "^-")

if [[ $# -eq 0 ]] || [[ first_option -eq 1 ]]; then
    # Run Jupyter Lab with default settings
    jupyter lab $@
else
    # If suffix is .py, execute python script with args
    if [[ $(echo $1 | grep -Ec ".*\.py$") -eq 1 ]]; then
        python $@
    # If suffix is .sh, execute the shell script with args
    elif [[ $(echo $1 | grep -Ec ".*\.sh$") -eq 1 ]]; then
        $@
    fi
fi