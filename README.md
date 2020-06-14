[![Build Status](https://travis-ci.org/SystemRDL/PeakRDL-uvm.svg?branch=master)](https://travis-ci.org/SystemRDL/PeakRDL-uvm)
[![PyPI - Python Version](https://img.shields.io/pypi/pyversions/peakrdl-uvm.svg)](https://pypi.org/project/peakrdl-uvm)

# PeakRDL-uvm
Generate UVM register model from compiled SystemRDL input

## Installing
Install from [PyPi](https://pypi.org/project/peakrdl-uvm) using pip:

    python3 -m pip install peakrdl-uvm

## Install from Github using pip
mkdir path_to_folder  
cd path_to_folder  
git clone https://github.com/muneebullashariff/PeakRDL-uvm.git  
cd to PeakRDL-uvm 
pip install -e .  

Advantages of this approach are:  
1 - You can install package in your home projects directory.  
2 - Package includes .git dir, so it's regular Git repository. You can push to your fork right away.  

## Uninstall   
pip uninstall systemrdl-compiler  
--------------------------------------------------------------------------------

## Exporter Usage
Pass the elaborated output of the [SystemRDL Compiler](http://systemrdl-compiler.readthedocs.io)
to the exporter.

```python
import sys
from systemrdl import RDLCompiler, RDLCompileError
from peakrdl.uvm import UVMExporter

rdlc = RDLCompiler()

try:
    rdlc.compile_file("path/to/my.rdl")
    root = rdlc.elaborate()
except RDLCompileError:
    sys.exit(1)

exporter = UVMExporter()
exporter.export(root, "test.sv")
```
--------------------------------------------------------------------------------

## Reference

### `UVMExporter(**kwargs)`
Constructor for the UVM Exporter class

**Optional Parameters**

* `user_template_dir`
    * Path to a directory where user-defined template overrides are stored.
* `user_template_context`
    * Additional context variables to load into the template namespace.

### `UVMExporter.export(node, path, **kwargs)`
Perform the export!

**Parameters**

* `node`
    * Top-level node to export. Can be the top-level `RootNode` or any internal `AddrmapNode`.
* `path`
    * Output file.

**Optional Parameters**

* `export_as_package`
    * If True (Default), UVM register model is exported as a SystemVerilog
      package. Package name is based on the output file name.
    * If False, register model is exported as an includable header.
* `reuse_class_definitions`
    * If True (Default), exporter attempts to re-use class definitions
      where possible. Class names are based on the lexical scope of the
      original SystemRDL definitions.
    * If False, class definitions are not reused. Class names are based on
      the instance's hierarchical path.
* `use_uvm_factory`
    * If True, class definitions and class instances are created using the
      UVM factory.
    * If False (Default), UVM factory is disabled. Classes are created
      directly via new() constructors.
