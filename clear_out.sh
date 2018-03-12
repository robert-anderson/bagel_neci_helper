#!/bin/bash

read -r -p "Are you sure? [y/N] " response
case "$response" in
    [yY][eE][sS]|[yY]) 
        ;;
    *)
        exit 0
        ;;
esac

rm neci_iter* -r 2> /dev/null

rm fciqmc_0_0.rdm* 2> /dev/null

rm *.out 2> /dev/null

rm relref.archive 2> /dev/null

rm this_neci_iter 2> /dev/null

rm last_neci_iter 2> /dev/null

rm casscf.log 2> /dev/null

rm neci.inp 2> /dev/null
