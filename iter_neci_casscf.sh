#!/bin/bash

root_dir=$(pwd)/$(dirname $0)

if [ -e ./bagel_neci_config.sh ]; then
    source ./bagel_neci_config.sh
else
    echo ERROR: bagel_neci_config.sh file missing
    exit 1
fi

if [ ! -d ./neci_iter_1 ]; then
    echo ERROR: no neci_iters found, please initialise CASSCF calc before proceeding with optimisation
    exit 1
fi

#########################################################

last_iter=$(ls -t . | grep neci_iter | grep -oE [0-9]+ | sort -n | tail -n1)

if [ -e ./fciqmc_0_0.rdm1 ]; then
    rm fciqmc_0_0.rdm1
fi

if [ -e ./fciqmc_0_0.rdm2 ]; then
    rm fciqmc_0_0.rdm2
fi

if [ ! -e ./neci_iter_$last_iter/1RDM.1 ]; then
    echo ERROR: 1RDM.1 not found in ./neci_iter_$last_iter
    exit 1
fi

if [ ! -e ./neci_iter_$last_iter/2RDM.1 ]; then
    echo ERROR: 2RDM.1 not found in ./neci_iter_$last_iter
    exit 1
fi

e_line1=$(grep 'TOTAL ENERGY' neci_iter_$last_iter/neci.out)

if [ "$last_iter" -gt "1" ]; then
    e_line2=$(grep "TOTAL ENERGY" neci_iter_$(echo $last_iter - 1 | bc)/neci.out)
    echo '2RDM energy' $(python ./energy_diffs.py "$e_line1") "  " $(python ./energy_diffs.py "$e_line2" "$e_line1")
else
    echo '2RDM energy' $(python ./energy_diffs.py "$e_line1")
fi

ln -s neci_iter_$last_iter/1RDM.1 fciqmc_0_0.rdm1
ln -s neci_iter_$last_iter/2RDM.1 fciqmc_0_0.rdm2

# do DHF and dump integrals
cat > bagel.json <<- EOM
{
    "bagel" : [
		$mol_chunk
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
	]
}
EOM

$bagel_exe bagel.json > 'bagel.casscf.'$last_iter'.out'

mkdir neci_iter_$(echo $last_iter + 1 | bc)

rm this_neci_iter 2> /dev/null
ln -s neci_iter_$(echo $last_iter + 1 | bc) this_neci_iter
rm last_neci_iter 2> /dev/null
ln -s neci_iter_$last_iter last_neci_iter

mv FCIDUMP this_neci_iter

if [ $production_run == "true" ] ; then
    cat > neci_iter_$(echo $last_iter + 1 | bc)/fciqmc.config <<- EOM
neciexepath              $neci_exe
totalwalkers             $totalwalkers
computenodes             $compute_nodes
walltime                 $walltime
initialruntime           $initialruntime
timepadding              $timepadding
name                     $name'_i'$(echo $last_iter + 1 | bc)
appendstats              no
intspath                 FCIDUMP
emailoptions             as
electrons                $nelec
spinrestrict             $spinrestrict
corespacesize            $corespacesize
trialwfsize              $trialwfsize
EOM

fi



