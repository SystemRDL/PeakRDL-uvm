#!/usr/bin/env python3

import sys
import os

import jinja2 as jj

from systemrdl import RDLCompiler, AddrmapNode, RegfileNode, MemNode, RegNode, FieldNode
from peakrdl.uvm import UVMExporter

#-------------------------------------------------------------------------------
testcase_name = sys.argv[1]
rdl_file = sys.argv[2]
output_dir = os.path.dirname(rdl_file)
#-------------------------------------------------------------------------------
# Generate UVM model
#-------------------------------------------------------------------------------
rdlc = RDLCompiler()
rdlc.compile_file(rdl_file)
root = rdlc.elaborate().top

uvm_exportname = os.path.join(output_dir, testcase_name + "_uvm.sv")

uvm_file = os.path.join(output_dir, testcase_name + "_uvm_nofac_reuse_pkg.sv")
UVMExporter().export(
    root, uvm_exportname,
    use_uvm_factory=False,
    reuse_class_definitions=True,
    export_as_package=True,
)
os.rename(uvm_exportname, uvm_file)

uvm_file = os.path.join(output_dir, testcase_name + "_uvm_fac_reuse_pkg.sv")
UVMExporter().export(
    root, uvm_exportname,
    use_uvm_factory=True,
    reuse_class_definitions=True,
    export_as_package=True,
)
os.rename(uvm_exportname, uvm_file)

uvm_file = os.path.join(output_dir, testcase_name + "_uvm_nofac_noreuse_pkg.sv")
UVMExporter().export(
    root, uvm_exportname,
    use_uvm_factory=True,
    reuse_class_definitions=False,
    export_as_package=True,
)
os.rename(uvm_exportname, uvm_file)

#-------------------------------------------------------------------------------
# Generate test logic
#-------------------------------------------------------------------------------
context = {
    'testcase_name': testcase_name,
    'root': root,
    'rn': root.inst_name,
    'isinstance': isinstance,
    'AddrmapNode': AddrmapNode,
    'RegfileNode': RegfileNode,
    'MemNode': MemNode,
    'RegNode': RegNode,
    'FieldNode': FieldNode,
}

template = jj.Template("""
module top();
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    `define ASSERT_EQ_STR(a,b) assert(a == b) else $error("%s != %s", a, b)
    `define ASSERT_EQ_INT(a,b) assert(a == b) else $error("0x%x != 0x%x", a, b)

    initial begin
        {{testcase_name}}_uvm::{{testcase_name}} {{rn}};
        {{rn}} = new("{{rn}}");
        {{rn}}.build();
        {{rn}}.lock_model();

        {% for node in root.descendants(unroll=True) %}
        // {{node}}
            {%- if isinstance(node, (AddrmapNode, RegfileNode, MemNode)) %}
        `ASSERT_EQ_STR({{node.get_path()}}.get_full_name(), "{{node.get_path()}}");
            {%- endif %}
            {%- if isinstance(node, RegNode) %}
                {%- if node.is_virtual %}
        `ASSERT_EQ_STR({{node.parent.get_path() + "." + node.inst_name}}.get_full_name(), "{{node.parent.get_path() + "." + node.inst_name}}");
        `ASSERT_EQ_INT({{node.parent.get_path() + "." + node.inst_name}}.get_size(), {{node.inst.n_elements}});
                {%- else %}
        `ASSERT_EQ_STR({{node.get_path()}}.get_full_name(), "{{node.get_path()}}");
        `ASSERT_EQ_INT({{node.get_path()}}.get_address(), {{"'h%x" % node.absolute_address}});
        `ASSERT_EQ_INT({{node.get_path()}}.get_n_bits(), {{node.get_property("regwidth")}});
                {%- endif %}
            {%- endif %}
            {%- if isinstance(node, FieldNode) %}
                {%- if node.is_virtual %}
        `ASSERT_EQ_STR({{node.parent.parent.get_path() + "." + node.parent.inst_name + "." + node.inst_name}}.get_full_name(), "{{node.parent.parent.get_path() + "." + node.parent.inst_name + "." + node.inst_name}}");
                {%- else %}
        `ASSERT_EQ_STR({{node.get_path()}}.get_full_name(), "{{node.get_path()}}");
        `ASSERT_EQ_INT({{node.get_path()}}.get_lsb_pos(), {{node.lsb}});
        `ASSERT_EQ_INT({{node.get_path()}}.get_n_bits(), {{node.width}});
                {%- endif %}
            {%- endif %}
        {%- endfor %}
    end
endmodule
""")

template.stream(context).dump(os.path.join(output_dir, testcase_name + "_test.sv"))
