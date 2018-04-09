#!/bin/bash

source ./utils.sh
check_source ./calc_config.sh

if [ "$trel" == "true" ] ; then
read -r -d '' scf_chunk << EOM
        {
            "title" : "dhf",
            "gaunt" : true,
            "breit" : true,
            "robust" : true,
            "thresh" : 1.0e-10,
            "maxiter" : 1000
        },
EOM
else
read -r -d '' scf_chunk << EOM
        {
            "title" : "hf"
        },
EOM
fi



if [ "$trel" == "true" ] ; then
read -r -d '' initial_casscf_chunk << EOM
        {
            "title"  : "zcasscf",
            "external_rdm" : "noref",
            "canonical" : $tpt2,
            "gaunt" : true,
            "breit" : true,
            "state" : [1],
            "maxiter" : 0,
            "nact" : $nact,
            "nclosed" : $nclosed
        },
        {
            "title" : "zfci",
            "only_ints" : true,
            "ncore" : $nclosed,
            "norb" :  $nact,
            "frozen" : false,
            "state" : [1]
        }
EOM
else
read -r -d '' initial_casscf_chunk << EOM
        {
            "title"  : "casscf",
            "external_rdm" : "noref",
            "canonical" : $tpt2,
            "nstate" : [1],
            "maxiter" : 0,
            "nact" : $nact,
            "nclosed" : $nclosed
        },
        {
            "title" : "fci",
            "only_ints" : true,
            "ncore" : $nclosed,
            "norb" :  $nact,
            "frozen" : false,
            "nstate" : 1
        }
EOM
fi


if [ "$trel" == "true" ] ; then
read -r -d '' casscf_chunk << EOM
        {
            "title": "zcasscf",
            "nclosed": $nclosed,
            "nact": $nact,
            "state" : [1],
            "external_rdm" : "fciqmc",
            "canonical" : $tpt2,
            "maxiter": 1
		},
		{
		    "title" : "zfci",
		    "only_ints" : true,
		    "ncore" : $nclosed,
		    "norb" : $nact,
		    "frozen" : false,
		    "state" : [1]
		}
EOM
else
read -r -d '' casscf_chunk << EOM
        {
            "title"  : "casscf",
            "external_rdm" : "fciqmc",
            "canonical" : $tpt2,
            "nstate" : [1],
            "maxiter" : 1,
            "nact" : $nact,
            "nclosed" : $nclosed
        },
        {
            "title" : "fci",
            "only_ints" : true,
            "ncore" : $nclosed,
            "norb" :  $nact,
            "frozen" : false,
            "nstate" : 1
        }
EOM
fi


if [ "$trel" == "true" ] ; then
read -r -d '' dump_fockmat_chunk << EOM
        {
            "state": [1],
            "nclosed": $nclosed,
            "title": "zcasscf",
            "maxiter_micro": 100,
            "algorithm" : "noopt",
            "nact": $nact,
            "external_rdm" : "fciqmc",
            "maxiter": 1
        },
        {
            "title" : "relsmith",
            "method" : "caspt2",
            "external_rdm" : "noref",
            "frozen" : false
        }
EOM
else
read -r -d '' dump_fockmat_chunk << EOM
        {
            "nstate": [
                1
            ],
            "nclosed": $nclosed,
            "title": "casscf",
            "maxiter_micro": 100,
            "algorithm" : "noopt",
            "nact": $nact,
            "external_rdm" : "fciqmc",
            "maxiter": 1
        },
        {
            "title" : "smith",
            "method" : "caspt2",
            "external_rdm" : "noref",
            "frozen" : false
        }
EOM
fi


if [ "$trel" == "true" ] ; then
read -r -d '' caspt2_chunk << EOM
        {
            "state": [1],
            "nclosed": $nclosed,
            "title": "zcasscf",
            "maxiter_micro": 100,
            "algorithm" : "noopt",
            "nact": $nact,
            "external_rdm" : "fciqmc",
            "maxiter": 1
        },
        {
            "title" : "relsmith",
            "method" : "caspt2",
            "external_rdm" : "fciqmc",
            "frozen" : false
        }
EOM
else
read -r -d '' caspt2_chunk << EOM
        {
            "nstate": [
                1
            ],
            "nclosed": $nclosed,
            "title": "casscf",
            "maxiter_micro": 100,
            "algorithm" : "noopt",
            "nact": $nact,
            "external_rdm" : "fciqmc",
            "maxiter": 1
        },
        {
            "title" : "smith",
            "method" : "caspt2",
            "external_rdm" : "fciqmc",
            "frozen" : false
        }
EOM
fi
