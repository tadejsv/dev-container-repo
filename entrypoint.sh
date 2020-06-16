#!/bin/bash

# Check if the first arg is an option (starts with -)
first_option=$(echo $1 | grep -Ec "^-")

if [[ $# -eq 0 ]]; then
    jupyter lab
elif [[ first_option -eq 1 ]]; then
    jupyter lab $@
elif  [[ $1 == "lab" ]] || [[ $1 == "notebook" ]]; then
    jupyter $@
else
    # If suffix is .py, execute python script with args
    if [[ $(echo $1 | grep -Ec ".*\.py$") -eq 1 ]]; then
        python $@
    # If suffix is .sh, execute the shell script with args
    elif [[ $(echo $1 | grep -Ec ".*\.sh$") -eq 1 ]]; then
        $@
    fi
fi