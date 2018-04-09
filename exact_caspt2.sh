#!/bin/bash

root_dir=$(pwd)/$(dirname $0)

source ./utils.sh

check_source ./env_config.sh
check_source ./calc_config.sh
check_source ./chunks.sh

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


if [ "$trel" == "true" ] ; then
cat > bagel.json <<- EOM
{
    "bagel" : [
		$mol_chunk
        $scf_chunk
        {
            "state": [1],
            "nclosed": $nclosed,
            "title": "zcasscf",
            "maxiter_micro": 100,
            "nact": $nact,
            "maxiter": 100
        },
        {
            "title" : "relsmith",
            "method" : "caspt2",
            "frozen" : false
        }
	]
}
EOM
else

cat > bagel.json <<- EOM
{
    "bagel" : [
		$mol_chunk
        $scf_chunk
        {
            "nstate": [1],
            "nclosed": $nclosed,
            "title": "casscf",
            "maxiter_micro": 100,
            "nact": $nact,
            "maxiter": 100
        },
        {
            "title" : "smith",
            "method" : "caspt2",
            "frozen" : false
        }
	]
}
EOM
fi

mv bagel.json bagel_exact_caspt2.json
$bagel_exe bagel_exact_caspt2.json > bagel.exact_caspt2.out

grep "CASPT2 energy" bagel.exact_caspt2.out
e_casscf=$(grep "Second-order optimization converged." -B2 bagel.exact_caspt2.out | grep -Eo "\-*[0-9]+\.+[0-9]+" | head -n1)
echo "CASSCF energy" $e_casscf
e_caspt2=$(sed -n -e '/---- iteration ----/,$p' bagel.exact_caspt2.out | grep -E "[0-9]+    \-*[0-9]+\.+[0-9]+     \-*[0-9]+\.+[0-9]+      \-*[0-9]+\.+[0-9]+" | tail -n 1 | grep -Eo "\-*[0-9]+\.+[0-9]+" | head -n1)
echo "CASPT2 correction" $e_caspt2
echo "CASPT2 energy" $(echo $e_casscf + $e_caspt2 | bc)

