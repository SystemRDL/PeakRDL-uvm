import sys
import os
from systemrdl import RDLCompiler, RDLCompileError
from peakrdl.uvm import UVMExporter

## Compile and elaborate the input .rdl file
rdlc = RDLCompiler()

src_rdl_fl = "tru_cfg.rdl"

try:
    rdlc.compile_file(src_rdl_fl)
    root = rdlc.elaborate()
except RDLCompileError:
    sys.exit(1)

## Generate the UVM output files
# Export as package or include files
export_as_package_l = False
if export_as_package_l:
    dest_uvm_fl = "tru_registers_pkg_uvm.sv" 
else:
    dest_uvm_fl = "tru_registers_uvm.sv" 

exporter = UVMExporter()

exporter.export(root, 
                dest_uvm_fl, 
                export_as_package=export_as_package_l, 
                use_uvm_factory=True, 
                use_uvm_reg_enhanced=False,
                use_uppercase_inst_name=True,
                reuse_class_definitions=False)

#strg = exporter._get_class_name(root)
#print (strg)
