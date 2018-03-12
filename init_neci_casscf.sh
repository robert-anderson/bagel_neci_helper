#!/bin/bash

root_dir=$(pwd)/$(dirname $0)

if [ -e ./bagel_neci_config.sh ]; then
    source ./bagel_neci_config.sh
else
    echo ERROR: bagel_neci_config.sh file missing
    exit 1
fi

if [ -d ./neci_iter_1 ]; then
    echo ERROR: neci_iters exist, please clean directory before initialising CASSCF calc
    exit 1
fi


#########################################################

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
            "title" : "zfci",
            "only_ints" : true,
            "ncore" : $nclosed,
            "norb" :  $nact,
            "frozen" : false,
            "state" : [1]
        }
	]
}
EOM
$bagel_exe bagel.json > bagel.initial.out

scf_energy=$(grep "SCF iteration converged" -B2 bagel.initial.out | grep -oE '\-*[0-9]+\.[0-9]+' | head -n1)
echo "Converged SCF energy:" $scf_energy


nelec=$(grep -oE "NELEC= [0-9]+" FCIDUMP | grep -oE [0-9]+)

mkdir neci_iter_1
mv FCIDUMP neci_iter_1
rm this_neci_iter 2> /dev/null
ln -s ./neci_iter_1 ./this_neci_iter

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
nonuniformrandexcits PICK-VIRT-UNIFORM
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
    
printonerdm
print-one-rdm-occupations
endlog
end
EOM
fi




