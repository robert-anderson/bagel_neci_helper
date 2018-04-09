#!/bin/bash

root_dir=$(pwd)/$(dirname $0)

source ./utils.sh

check_source ./env_config.sh
check_source ./calc_config.sh
check_source ./chunks.sh

#########################################################

# do DHF and dump integrals
cat > bagel.json <<- EOM
{
    "bagel" : [
		$mol_chunk
        $scf_chunk
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
echo "CASSCF energy:" $(grep -E "[0-9]+   [0-9]+  \*     \-+[0-9]+\.[0-9]+" bagel.exact_casscf.out | grep -oE "\-+[0-9]+\.[0-9]+")
