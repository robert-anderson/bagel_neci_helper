#!/bin/bash

root_dir=$(pwd)/$(dirname $0)

bagel_exe='/home/mmm0043/Programs/bagel_master/obj/src/BAGEL'
neci_exe='/home/mmm0043/Programs/neci_hbrdm/build_debug/bin/kneci'

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



#########################################################

# first, clear out working directory
# for i in $(ls | grep -v 'run.sh'); do rm $i; done


# do DHF and dump integrals
cat > bagel.json <<- EOM
{
    "bagel" : [
		$mol_chunk
        {
            "title" : "dhf",
            "gaunt" : true,
            "breit" : true,
            "robust" : true,
            "thresh" : 1.0e-10,
            "maxiter" : 1000
        },
        {
            "nclosed": $nclosed,
            "title": "zcasscf",
            "nact": $nact,
		    "state" : [1],
            "maxiter": 100
        }
	]
}
EOM
$bagel_exe bagel.json > bagel.exact_casscf.out
