{% import 'utils.sv' as utils with context %}

//------------------------------------------------------------------------------
// uvm_reg_block definition
//------------------------------------------------------------------------------
{% macro class_definition(node) -%}
{%- if class_needs_definition(node) %}
// {{get_class_friendly_name(node)}}
class {{get_class_name(node)}} extends uvm_reg_block;
{%- if use_uvm_factory %}
    `uvm_object_utils({{get_class_name(node)}})
{%- endif %}
    {{child_insts(node)|indent}}
{%- if coverage and node.registers() -%}
    {{cov_bins(node)|indent}}
    {{cg_inst(node)|indent}}
{% endif %}
    {{function_new(node)|indent}}

    {{function_build(node)|indent}}
{% if coverage and node.registers() %}
    {{function_sample()|indent}}
{% endif %}
endclass : {{get_class_name(node)}}
{% endif -%}
{%- endmacro %}


//------------------------------------------------------------------------------
// Child instances
//------------------------------------------------------------------------------
{% macro child_insts(node) -%}
{%- for child in node.children() if isinstance(child, AddressableNode) -%}
rand {{get_class_name(child)}} {{get_inst_name(child)}}{{utils.array_inst_suffix(child)}};
{% endfor -%}
{%- endmacro %}


//------------------------------------------------------------------------------
// Coverage bins for arrays
//------------------------------------------------------------------------------
{% macro cov_bins(node) -%}
{%- for child in node.children() if isinstance(child, RegNode) -%}
{%- if child.is_array %}
local uvm_reg_addr_t {{get_inst_name(child)}}_bins[$];
{% endif %}
{%- endfor %}
{%- endmacro %}


//------------------------------------------------------------------------------
// Covergroup instance
//------------------------------------------------------------------------------
{% macro cg_inst(node) -%}
covergroup addr_cg with function sample(uvm_reg_addr_t offset, bit is_read);
    option.per_instance = 1;

    addr_cp: coverpoint offset {
        {%- for child in node.children() if isinstance(child, RegNode) -%}
        {%- if child.is_array %}
        {%- for dim in child.array_dimensions %}
        bins {{get_inst_name(child)}}[] = {{get_inst_name(child)}}_bins;
        {%- endfor -%}
        {%- else %}
        bins {{get_inst_name(child)}} = { {{"'h%x" % child.raw_address_offset}} };
        {%- endif %}
        {%- endfor %}
    }
    
    dir_cp: coverpoint is_read {
        bins read  = {1'b1};
        bins write = {1'b0};
    }
    
    access_cp: cross addr_cp, dir_cp;
    
endgroup: addr_cg
{%- endmacro %}


//------------------------------------------------------------------------------
// new() function
//------------------------------------------------------------------------------
{% macro function_new(node) -%}
function new(string name = "{{get_class_name(node)}}");
    {%- if coverage and node.registers() %}
    super.new(name, build_coverage(UVM_CVR_ADDR_MAP));

    if (has_coverage(UVM_CVR_ADDR_MAP)) begin
    {%- for child in node.children() if isinstance(child, RegNode) -%}
    {%- if child.is_array %}
        foreach({{get_inst_name(child)}}[{{utils.array_iterator_list(child)}}])
            {{get_inst_name(child)}}_bins.push_back({{get_array_address_offset_expr(child)}});
    {% endif %}
    {%- endfor %}
        addr_cg = new();
    end
    {%- else %}
    super.new(name);
    {%- endif %}
endfunction : new
{%- endmacro %}


//------------------------------------------------------------------------------
// build() function
//------------------------------------------------------------------------------
{% macro function_build(node) -%}
virtual function void build();
    this.default_map = create_map("reg_map", 0, {{get_bus_width(node)}}, {{get_endianness(node)}});
    {%- for child in node.children() -%}
        {%- if isinstance(child, RegNode) -%}
            {{uvm_reg.build_instance(child)|indent}}
        {%- elif isinstance(child, (RegfileNode, AddrmapNode)) -%}
            {{build_instance(child)|indent}}
        {%- elif isinstance(child, MemNode) -%}
            {{uvm_reg_block_mem.build_instance(child)|indent}}
        {%- endif -%}
    {%- endfor %}

    {%- if coverage and node.registers() %}
    void'(set_coverage(UVM_CVR_ADDR_MAP));
    {%- endif %}
endfunction : build
{%- endmacro %}


//------------------------------------------------------------------------------
// build() actions for uvm_reg_block instance (called by parent)
//------------------------------------------------------------------------------
{% macro build_instance(node) -%}
{%- if node.is_array %}
foreach(this.{{get_inst_name(node)}}[{{utils.array_iterator_list(node)}}]) begin
    {%- if use_uvm_factory %}
    this.{{get_inst_name(node)}}{{utils.array_iterator_suffix(node)}} = {{get_class_name(node)}}::type_id::create($sformatf("{{get_inst_name(node)}}{{utils.array_suffix_format(node)}}", {{utils.array_iterator_list(node)}}));
    {%- else %}
    this.{{get_inst_name(node)}}{{utils.array_iterator_suffix(node)}} = new($sformatf("{{get_inst_name(node)}}{{utils.array_suffix_format(node)}}", {{utils.array_iterator_list(node)}}));
    {%- endif %}
    {%- if node.get_property('hdl_path') %}
    this.{{get_inst_name(node)}}{{utils.array_iterator_suffix(node)}}.configure(this, "{{node.get_property('hdl_path')}}");
    {%- else %}
    this.{{get_inst_name(node)}}{{utils.array_iterator_suffix(node)}}.configure(this);
    {%- endif %}
    {%- if node.get_property('hdl_path_gate') %}
    this.{{get_inst_name(node)}}{{utils.array_iterator_suffix(node)}}.add_hdl_path("{{node.get_property('hdl_path_gate')}}", "GATE");
    {%- endif %}
    this.{{get_inst_name(node)}}{{utils.array_iterator_suffix(node)}}.build();
    this.default_map.add_submap(this.{{get_inst_name(node)}}{{utils.array_iterator_suffix(node)}}.default_map, {{get_array_address_offset_expr(node)}});
end
{%- else %}
{%- if use_uvm_factory %}
this.{{get_inst_name(node)}} = {{get_class_name(node)}}::type_id::create("{{get_inst_name(node)}}");
{%- else %}
this.{{get_inst_name(node)}} = new("{{get_inst_name(node)}}");
{%- endif %}
{%- if node.get_property('hdl_path') %}
this.{{get_inst_name(node)}}.configure(this, "{{node.get_property('hdl_path')}}");
{%- else %}
this.{{get_inst_name(node)}}.configure(this);
{%- endif %}
{%- if node.get_property('hdl_path_gate') %}
this.{{get_inst_name(node)}}.add_hdl_path("{{node.get_property('hdl_path_gate')}}", "GATE");
{%- endif %}
this.{{get_inst_name(node)}}.build();
this.default_map.add_submap(this.{{get_inst_name(node)}}.default_map, {{"'h%x" % node.raw_address_offset}});
{%- endif %}
{%- endmacro %}


//------------------------------------------------------------------------------
// sample() function
//------------------------------------------------------------------------------
{% macro function_sample() -%}
virtual function void sample(uvm_reg_addr_t offset, bit is_read, uvm_reg_map map);
    if (get_coverage(UVM_CVR_ADDR_MAP)) begin
        addr_cg.sample(offset, is_read);
    end
endfunction: sample
{%- endmacro %}
  
