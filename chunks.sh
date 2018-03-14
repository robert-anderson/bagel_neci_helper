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






