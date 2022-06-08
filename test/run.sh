#!/bin/bash

set -e

this_dir="$( cd "$(dirname "$0")" ; pwd -P )"

exists () {
  type "$1" >/dev/null 2>/dev/null
}

# Initialize venv
venv_bin=$this_dir/.venv/bin
python3 -m venv $this_dir/.venv

#tools
python=$venv_bin/python
pylint=$venv_bin/pylint


# Install test dependencies
$python -m pip install -U pylint setuptools pip


# Install dut
cd $this_dir/..
$python setup.py install
cd $this_dir


# Generate testcase verilog files
$python generate_testcase_data.py basic testcases/basic.rdl


# Run modelsim testcases
if exists vsim; then
    ./vsim_test.sh testcases/basic_uvm_nofac_reuse_pkg.sv testcases/basic_test.sv
    ./vsim_test.sh testcases/basic_uvm_fac_reuse_pkg.sv testcases/basic_test.sv
    ./vsim_test.sh testcases/basic_uvm_nofac_noreuse_pkg.sv testcases/basic_test.sv
fi


# Run lint
$pylint --rcfile $this_dir/pylint.rc ../src/peakrdl_uvm | tee $this_dir/lint.rpt
