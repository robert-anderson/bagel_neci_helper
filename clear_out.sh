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
rm neci_caspt2 -r 2> /dev/null
rm fciqmc_0_0.rdm* 2> /dev/null
rm *.out 2> /dev/null
rm ref.archive 2> /dev/null
rm ref.archive_save 2> /dev/null
rm relref.archive 2> /dev/null
rm relref.archive_save 2> /dev/null
rm this_neci_iter 2> /dev/null
rm last_neci_iter 2> /dev/null
rm casscf.log 2> /dev/null
rm neci.inp 2> /dev/null
rm neci.highbody.inp 2> /dev/null
rm bagel.json 2> /dev/null
rm FCIDUMP 2> /dev/null
rm FOCKMAT 2> /dev/null
