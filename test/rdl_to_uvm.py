#!/usr/bin/env python3

import sys
import os

from systemrdl import RDLCompiler
from peakrdl_uvm import UVMExporter


rdl_file = sys.argv[1]
sv_file = sys.argv[2]

rdlc = RDLCompiler()
rdlc.compile_file(rdl_file)
root = rdlc.elaborate().top

UVMExporter().export(
    root, sv_file,
    use_uvm_factory=False,
    reuse_class_definitions=True,
    export_as_package=True,
)
