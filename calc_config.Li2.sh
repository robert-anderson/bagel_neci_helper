#!/bin/bash

# example calculation

trel=false
tpt2=true
nclosed=0
nact=5

read -r -d '' mol_chunk << EOM
        {
            "geometry": [
                {
                    "xyz": [
                        -0.0,
                        -0.0,
                        -0.0
                    ],
                    "atom": "Li"
                },
                {
                    "xyz": [
                        1.0,
                        -0.0,
                        -0.0
                    ],
                    "atom": "Li"
                }
            ],
            "df_basis": "/home/mmm0043/Programs/bagel_master/src/basis/cc-pvdz.json",
            "basis": "/home/mmm0043/Programs/bagel_master/src/basis/cc-pvdz.json",
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
name='Li2_zcasscf'
spinrestrict=0
corespacesize=250
trialwfsize=20

