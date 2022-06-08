import warnings

# Load modules
from peakrdl_uvm import __about__
from peakrdl_uvm import exporter
from peakrdl_uvm import pre_export_listener

# hoist internal objects
from peakrdl_uvm.__about__ import __version__
from peakrdl_uvm.exporter import UVMExporter

warnings.warn(
"""
================================================================================
Importing via namespace package 'peakrdl.uvm' is deprecated and will be
removed in the next release.
Change your imports to load the package using 'peakrdl_uvm' instead.
For more details, see: https://github.com/SystemRDL/PeakRDL/issues/4
================================================================================
""", DeprecationWarning, stacklevel=2)
