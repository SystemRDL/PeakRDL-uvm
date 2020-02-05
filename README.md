[![PyPI - Python Version](https://img.shields.io/pypi/pyversions/ralbot-uvm.svg)](https://pypi.org/project/ralbot-uvm)

# RALBot-uvm
Generate UVM register model from compiled SystemRDL input

## Installing
Install from [PyPi](https://pypi.org/project/ralbot-uvm) using pip:

    python3 -m pip install ralbot-uvm

--------------------------------------------------------------------------------

## Exporter Usage
Pass the elaborated output of the [SystemRDL Compiler](http://systemrdl-compiler.readthedocs.io)
to the exporter.

```python
import sys
from systemrdl import RDLCompiler, RDLCompileError
from ralbot.uvmgen import uvmGenExporter

rdlc = RDLCompiler()

try:
    rdlc.compile_file("path/to/my.rdl")
    root = rdlc.elaborate()
except RDLCompileError:
    sys.exit(1)

file = "test.svh"
exporter = uvmGenExporter()
exporter.export(root, file)
```
--------------------------------------------------------------------------------

## Reference

### `uvmGenExporter(**kwargs)`
Constructor for the uvmGen exporter class

**Optional Parameters**

* `indentLvl`
    * String to use for each indent level. Defaults to three spaces.

### `uvmGenExporter.export(node, path)`
Perform the export!

**Parameters**

* `node`
    * Top-level node to export. Can be the top-level `RootNode` or any internal `AddrmapNode`.
* `path`
    * Output file. Can be (dir+filename without suffix. such as "output/test_uvmgen")
