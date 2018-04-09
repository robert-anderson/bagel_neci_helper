#!/bin/bash

source ./utils.sh
check_source ./calc_config.sh
check_source ./env_config.sh
check_source ./chunks.sh

if [ -d ./neci_iter_1 ]; then
    fatal_error "neci_iters exist, please clean directory before initialising CASSCF calc"
fi

if [ $trel == "true" ] ; then
    neci_exe=$neci_bin_path/kneci
else
    neci_exe=$neci_bin_path/neci
fi

MAX_ITER=10
TOL="1e-8"

sh init_neci_casscf.sh

for it in $(seq 1 $MAX_ITER); do
    echo "iteration" $it "..."
    cd this_neci_iter
    $neci_exe ../neci.inp > neci.out
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

if [ "$tpt2" == "false" ] ; then
    exit 0;
fi

cat > bagel.json <<- EOM
{
    "bagel" : [
		$mol_chunk
		$dump_fockmat_chunk
	]
}
EOM

$bagel_exe bagel.json > 'bagel.dump_fockmat.out'

python reformat_fockmat.py

mkdir neci_caspt2
mv FOCKMAT neci_caspt2
cd neci_caspt2
ln -s ../FCIDUMP FCIDUMP
$neci_exe ../neci.highbody.inp > neci.highbody.out
cd ~-

if [ "$trel" == "true" ]; then
    archive_file="relref.archive"
    rdm1_filename="1RDM.1"
    rdm2_filename="2RDM.1"
    rdm3_filename="3RDM.1"
    caspt2_aux_filename="CASPT2_AUX.1"
else
    archive_file="ref.archive"
    rdm1_filename="spinfree_OneRDM.1"
    rdm2_filename="spinfree_TwoRDM.1"
    rdm3_filename="spinfree_ThreeRDM.1"
    caspt2_aux_filename="spinfree_CASPT2_AUX.1"
fi

if [ -e ./fciqmc_0_0.rdm1 ]; then
    rm fciqmc_0_0.rdm1
fi

if [ -e ./fciqmc_0_0.rdm2 ]; then
    rm fciqmc_0_0.rdm2
fi
ln -s neci_caspt2/$rdm1_filename fciqmc_0_0.rdm1
ln -s neci_caspt2/$rdm2_filename fciqmc_0_0.rdm2
ln -s neci_caspt2/$rdm3_filename fciqmc_0_0.rdm3
ln -s neci_caspt2/$caspt2_aux_filename fciqmc_0_0.rdm4f

cat > bagel.json <<- EOM
{
    "bagel" : [
		$mol_chunk
		$caspt2_chunk
	]
}
EOM

$bagel_exe bagel.json > 'bagel.caspt2.out'
