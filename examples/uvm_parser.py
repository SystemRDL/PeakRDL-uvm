##import sys
##import os
##from systemrdl import RDLCompiler, RDLCompileError
##from peakrdl.uvm import UVMExporter
##
#### Compile and elaborate the input .rdl file
##rdlc = RDLCompiler()
##
##src_rdl_fl = "tru_cfg.rdl"
##
##try:
##    rdlc.compile_file(src_rdl_fl)
##    root = rdlc.elaborate()
##except RDLCompileError:
##    sys.exit(1)
##
#### Generate the UVM output files
### Export as package or include files
##export_as_package_l = False
##if export_as_package_l:
##    dest_uvm_fl = "tru_registers_pkg_uvm.sv" 
##else:
##    dest_uvm_fl = "tru_registers_uvm.sv" 
##
##exporter = UVMExporter()
##
##exporter.export(root, 
##                dest_uvm_fl, 
##                export_as_package=export_as_package_l, 
##                use_uvm_factory=True, 
##                has_coverage=True,
##                use_uvm_reg_enhanced=False,
##                use_uppercase_inst_name=True,
##                reuse_class_definitions=False)
##
###strg = exporter._get_class_name(root)
###print (strg)

import sys
import os
import re

from systemrdl import RDLCompiler, RDLCompileError
from systemrdl.node import RootNode, Node, RegNode, AddrmapNode, RegfileNode
from systemrdl.node import FieldNode, MemNode, AddressableNode
from peakrdl.uvm import UVMExporter

# Get the input .rdl file from the command line
input_files = sys.argv[1:]

## Compile and elaborate the input .rdl file
rdlc = RDLCompiler()

## List for storing the elaborated ouput of each .rdl file
rdlc_elab_list = []

## Compile and store the elaborated object
try:
    for input_file in input_files:
        rdlc.compile_file(input_file)
        rdlc_elab_list.append(rdlc.elaborate())

except RDLCompileError:
    sys.exit(1)

# Export as package or include files
export_as_package_l       = True 
use_uvm_factory_l         = True
has_coverage_l            = True
has_hdl_path_l            = True 
use_uvm_reg_enhanced_l    = False
use_uppercase_inst_name_l = True

## Derive the output file(s) name
output_files = []
for in_fl in input_files:
    match = re.search(r"(.*?).rdl",str(in_fl))
    #match = re.search(r"input/(.*?).rdl",str(in_fl))
    if match:
        if export_as_package_l:
            var_out = match.group(1) + "_uvm_pkg.sv"
        else:
            var_out = match.group(1) + "_uvm.sv"
        output_files.append(var_out)

if export_as_package_l:
    package_file_name = "example_registers_uvm_pkg.sv"

# Generate the UVM output files
exporter = UVMExporter()

# Loop through all the input files 
for root_id, root in enumerate(rdlc_elab_list):
    exporter.export(root, 
                    output_files[root_id], 
                    export_as_package       = export_as_package_l, 
                    use_uvm_factory         = use_uvm_factory_l, 
                    has_coverage            = has_coverage_l,
                    has_hdl_path            = has_hdl_path_l,
                    use_uvm_reg_enhanced    = use_uvm_reg_enhanced_l,
                    use_uppercase_inst_name = use_uppercase_inst_name_l,
                    reuse_class_definitions = False)

print("[INFO] Successfully generated the output UVM files")
