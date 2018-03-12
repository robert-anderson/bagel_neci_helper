#!/bin/bash

bagel_exe='/home/mmm0043/Programs/bagel_master/obj/src/BAGEL'
neci_exe='/home/mmm0043/Programs/neci_hbrdm/build_debug/bin/kneci'

nclosed=2
nact=4

read -r -d '' mol_chunk << EOM
        {
            "geometry": [
                {
                    "xyz": [
                        -0.0,
                        -0.0,
                        -0.0
                    ],
                    "atom": "Ne"
                }
            ],
            "basis": "/home/mmm0043/Programs/bagel_master/src/basis/cc-pvdz.json",
            "df_basis": "/home/mmm0043/Programs/bagel_master/src/basis/cc-pvdz-jkfit.json",
            "angstrom": true,
            "title": "molecule"
        },
EOM

# is this a production or test mode calculation?
production_run=false

# The following are only required if in production run mode:
totalwalkers=500k
compute_nodes=3
walltime=2h
initialruntime=20m
timepadding=10m
name='Ne_zcasscf'
spinrestrict=0
corespacesize=250
trialwfsize=20

