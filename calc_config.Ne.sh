#!/bin/bash

# example calculation

trel=true
nclosed=1
nact=7

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

# if this is true, we save the archive file and optionally accept the iteration if the
# rdm is considered good enough
multi_attempt=false

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

