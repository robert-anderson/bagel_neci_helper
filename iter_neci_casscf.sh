#!/bin/bash

root_dir=$(pwd)/$(dirname $0)

source ./utils.sh

check_source ./env_config.sh
check_source ./calc_config.sh
check_source ./chunks.sh

if [ ! -d ./neci_iter_1 ]; then
    fatal_error "no neci_iters found, please initialise CASSCF calc before proceeding with optimisation"
fi

if [ $trel == "true" ] ; then
    neci_exe=$neci_bin_path/kneci
else
    neci_exe=$neci_bin_path/neci
fi

#########################################################

last_iter=$(ls -t . | grep neci_iter | grep -oE [0-9]+ | sort -n | tail -n1)

if [ -e ./fciqmc_0_0.rdm1 ]; then
    rm fciqmc_0_0.rdm1
fi

if [ -e ./fciqmc_0_0.rdm2 ]; then
    rm fciqmc_0_0.rdm2
fi

if [ "$trel" == "true" ]; then
    archive_file="relref.archive"
    rdm1_filename="1RDM.1"
    rdm2_filename="2RDM.1"
else
    archive_file="ref.archive"
    rdm1_filename="spinfree_OneRDM.1"
    rdm2_filename="spinfree_TwoRDM.1"
fi


if [ ! -e ./neci_iter_$last_iter/$rdm1_filename ]; then
    echo ERROR: $rdm1_filename not found in ./neci_iter_$last_iter
    exit 1
fi

if [ ! -e ./neci_iter_$last_iter/$rdm2_filename ]; then
    echo ERROR: $rdm2_filename not found in ./neci_iter_$last_iter
    exit 1
fi

e_line1=$(grep 'TOTAL ENERGY' neci_iter_$last_iter/neci.out)

if [ "$last_iter" -gt "1" ]; then
    e_line2=$(grep "TOTAL ENERGY" neci_iter_$(echo $last_iter - 1 | bc)/neci.out)
    echo '2RDM energy' $(python ./energy_diffs.py "$e_line1") "  " $(python ./energy_diffs.py "$e_line2" "$e_line1")
else
    echo '2RDM energy' $(python ./energy_diffs.py "$e_line1")
fi

ln -s neci_iter_$last_iter/$rdm1_filename fciqmc_0_0.rdm1
ln -s neci_iter_$last_iter/$rdm2_filename fciqmc_0_0.rdm2


cat > bagel.json <<- EOM
{
    "bagel" : [
		$mol_chunk
		$casscf_chunk
	]
}
EOM

if [ "$multi_attempt" == "true" ]; then
    cp $archive_file $archive_file"_save"
fi

$bagel_exe bagel.json > 'bagel.casscf.'$last_iter'.out'

if [ "$multi_attempt" == "true" ]; then
read -r -p "Accept this iteration? [y/N] " response
case "$response" in
    [yY][eE][sS]|[yY]) 
        ;;
    *)
        mv $archive_file"_save" relref.archive
        echo "Pre-iteration orbitals restored, aborting CASSCF iteration"
        exit 0
        ;;
esac
fi

mkdir neci_iter_$(echo $last_iter + 1 | bc)

rm this_neci_iter 2> /dev/null
ln -s neci_iter_$(echo $last_iter + 1 | bc) this_neci_iter
rm last_neci_iter 2> /dev/null
ln -s neci_iter_$last_iter last_neci_iter

ln -s ../FCIDUMP this_neci_iter/FCIDUMP

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



