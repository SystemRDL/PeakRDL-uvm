#!/usr/bin/env python3

import sys
import os

# Ignore this. Only needed for this example
this_dir = os.path.dirname(os.path.realpath(__file__))
sys.path.insert(0, os.path.join(this_dir, "../"))


from systemrdl import RDLCompiler, RDLListener, RDLWalker, RDLCompileError
from systemrdl.node import FieldNode, RegNode, AddrmapNode, SignalNode
from ralbot.uvmgen import uvmGenExporter

# Collect input files from the command line arguments
input_files = sys.argv[1:]

# Create an instance of the compiler
rdlc = RDLCompiler()

try:
    # Compile all the files provided
    for input_file in input_files:
        rdlc.compile_file(input_file)
    
    # Elaborate the design
    root = rdlc.elaborate()
except RDLCompileError:
    # A compilation error occurred. Exit with error code
    sys.exit(1)


file = "test.svh"
headerfile = uvmGenExporter()
headerfile.export(root, file)
