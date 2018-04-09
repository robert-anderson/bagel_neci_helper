#!/bin/bash

root_dir=$(pwd)/$(dirname $0)

source ./utils.sh

check_source ./env_config.sh
check_source ./calc_config.sh
check_source ./chunks.sh

if [ -d ./neci_iter_1 ]; then
    fatal_error "neci_iters exist, please clean directory before initialising CASSCF calc"
fi

if [ $trel == "true" ] ; then
    neci_exe=$neci_bin_path/kneci
else
    neci_exe=$neci_bin_path/neci
fi

#########################################################

# do DHF and dump integrals
cat > bagel.json <<- EOM
{
    "bagel" : [
		$mol_chunk
		$scf_chunk
        $initial_casscf_chunk
	]
}
EOM
$bagel_exe bagel.json > bagel.initial.out

scf_energy=$(grep "SCF iteration converged" -B2 bagel.initial.out | grep -oE '\-*[0-9]+\.[0-9]+' | head -n1)
echo "Converged SCF energy:" $scf_energy


nelec=$(grep -oE "NELEC= [0-9]+" FCIDUMP | grep -oE [0-9]+)

mkdir neci_iter_1
rm this_neci_iter 2> /dev/null
ln -s ./neci_iter_1 ./this_neci_iter
ln -s ../FCIDUMP this_neci_iter/FCIDUMP

if [ $trel == "true" ] ; then
    spinfree_line=""
    excitgen_line="nonuniformrandexcits PICK-VIRT-UNIFORM"
else
    spinfree_line="write-spin-free-rdm"
    excitgen_line="nonuniformrandexcits 4IND-WEIGHTED"
fi


if [ $production_run == "true" ] ; then
    cat > neci_iter_1/fciqmc.config <<- EOM
neciexepath              $neci_exe
totalwalkers             $totalwalkers
computenodes             $compute_nodes
walltime                 $walltime
initialruntime           $initialruntime
timepadding              $timepadding
name                     $name'_i1'
appendstats              no
intspath                 FCIDUMP
emailoptions             as
electrons                $nelec
spinrestrict             $spinrestrict
corespacesize            $corespacesize
trialwfsize              $trialwfsize
EOM

else
    cat > neci.inp <<- EOM
title

system read noorder
symignoreenergies
freeformat
electrons $nelec

sym 0 0 0 0
$excitgen_line
nobrillouintheorem
endsys

calc
methods
method vertex fcimc
endmethods
fci-init

tau 0.01
memoryfacpart 2.0
memoryfacspawn 20.0
totalwalkers 5000
nmcyc 4000
seed 17
startsinglepart 100
diagshift 0.100000
rdmsamplingiters 200000
shiftdamp 0.05
truncinitiator
addtoinitiator 3
allrealcoeff
realspawncutoff 0.4
jump-shift
proje-changeref 1.5
stepsshift 10
maxwalkerbloom 3
load-balance-blocks off
LANCZOS-ENERGY-PRECISION 10
endcalc

integral
freeze 0 0
endint

logging
binarypops
exactrdm
explicitallrdm

calcrdmonfly 3 1000 5000
    
$spinfree_line
printonerdm
print-one-rdm-occupations
endlog
end
EOM
    cat > neci.highbody.inp <<- EOM
title

system read noorder
symignoreenergies
freeformat
electrons $nelec

sym 0 0 0 0
$excitgen_line
nobrillouintheorem
endsys

calc
methods
method vertex fcimc
endmethods
fci-init

tau 0.01
memoryfacpart 2.0
memoryfacspawn 20.0
totalwalkers 5000
nmcyc 4000
seed 17
startsinglepart 100
diagshift 0.100000
rdmsamplingiters 200000
shiftdamp 0.05
truncinitiator
addtoinitiator 3
allrealcoeff
realspawncutoff 0.4
jump-shift
proje-changeref 1.5
stepsshift 10
maxwalkerbloom 3
load-balance-blocks off
LANCZOS-ENERGY-PRECISION 10
endcalc

integral
freeze 0 0
endint

logging
binarypops
exactrdm
explicitallrdm

calcrdmonfly 3 1000 5000

four-body-rdm
caspt2-intermediate
    
$spinfree_line
printonerdm
print-one-rdm-occupations
endlog
end
EOM
fi
