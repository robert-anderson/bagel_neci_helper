#!/bin/bash

fatal_error () {
    echo ERROR: $1
    exit 1
}

check_source () {
    if [ -e $1 ]; then
        source $1
    else
        fatal_error "$1 file missing"
    fi
}
