#!/bin/bash

if [ -d ./neci_iter_1 ]; then
    echo ERROR: neci_iters exist, please clean directory before initialising CASSCF calc
    exit 1
fi

MAX_ITER=20
TOL="1e-8"

sh init_neci_casscf.sh

for it in $(seq 1 $MAX_ITER); do
    echo "iteration" $it "..."
    cd this_neci_iter
    /home/mmm0043/Programs/neci_hbrdm/build_debug/bin/kneci ../neci.inp > neci.out
    cd ~-

    if [ "$it" -gt "1" ]; then
        e_line2=$(grep 'TOTAL ENERGY' last_neci_iter/neci.out)
    fi

    sh iter_neci_casscf.sh

    if [ "$it" -gt "1" ]; then
        e_line1=$(grep 'TOTAL ENERGY' last_neci_iter/neci.out)
        result=$(python energy_diffs.py check "$e_line1" "$e_line2" "$TOL")
        if [ "$result" == "true" ]; then
            echo "Convergence reached"
            break
        fi
    fi

done

if [ "$it" == "$MAX_ITER" ] ; then
    echo "Maximum iteration number reached"
fi
