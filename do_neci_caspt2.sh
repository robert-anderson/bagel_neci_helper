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

if [ "$trel" == "true" ]; then
    archive_file="relref.archive"
    rdm1_filename="1RDM.1"
    rdm2_filename="2RDM.1"
else
    archive_file="ref.archive"
    rdm1_filename="spinfree_OneRDM.1"
    rdm2_filename="spinfree_TwoRDM.1"
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

cat > bagel.json <<- EOM
{
    "bagel" : [
		$mol_chunk
		$caspt2_chunk
	]
}
EOM

$bagel_exe bagel.json > 'bagel.caspt2.out'

#
#
#if [ "$multi_attempt" == "true" ]; then
#    cp $archive_file $archive_file"_save"
#fi
#
#$bagel_exe bagel.json > 'bagel.caspt2.out'
#
#if [ "$multi_attempt" == "true" ]; then
#read -r -p "Accept this iteration? [y/N] " response
#case "$response" in
#    [yY][eE][sS]|[yY]) 
#        ;;
#    *)
#        mv $archive_file"_save" relref.archive
#        echo "Pre-iteration orbitals restored, aborting CASSCF iteration"
#        exit 0
#        ;;
#esac
#fi
#
#mkdir neci_pt2
#
#rm this_neci_iter 2> /dev/null
#ln -s neci_iter_$(echo $last_iter + 1 | bc) this_neci_iter
#rm last_neci_iter 2> /dev/null
#ln -s neci_iter_$last_iter last_neci_iter
#
#ln -s ../FCIDUMP this_neci_iter/FCIDUMP
#
#

