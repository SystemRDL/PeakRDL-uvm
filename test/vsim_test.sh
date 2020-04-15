#!/bin/bash

set -e

vlog_args="-quiet -sv -L questa_uvm_pkg +incdir+$UVM_SRC"
vsim_args="-quiet -L questa_uvm_pkg +UVM_NO_RELNOTES"
do_script="
    run -all;
    exit;
"

rm -rf work transcript *.wlf
vlog $vlog_args $@
vsim $vsim_args -c top -do "$do_script"

if grep -Pq "(Error:|Fatal:|UVM_ERROR|UVM_FATAL)" transcript; then
    echo Sim had errors
    exit 1
fi
