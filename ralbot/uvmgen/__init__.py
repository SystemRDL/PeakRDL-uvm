from .__about__ import __version__

from .exporter import uvmGenExporter

import warnings
warnings.warn(
"""
================================================================================
The RALBot-uvm project has been deprecated and renamed to PeakRDL-uvm.
Please update your dependencies to continue receiving the latest updates.
For details, see: https://github.com/SystemRDL/PeakRDL/issues/2
================================================================================
"""
) 
