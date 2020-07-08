{% import 'utils.sv' as utils with context %}

//------------------------------------------------------------------------------
// uvm_reg definition
//------------------------------------------------------------------------------
{% macro class_definition(node) -%}
{%- if class_needs_definition(node) %}
//-----------------------------------------------------------------------------
// {{get_class_friendly_name(node)}}
//-----------------------------------------------------------------------------
{%- if use_uvm_reg_enhanced %}
class {{get_class_name(node)}} extends uvm_reg_enhanced;
{%- else %}
class {{get_class_name(node)}} extends uvm_reg;
{%- endif %}
{%- if use_uvm_factory %}
    `uvm_object_utils({{get_class_name(node)}})
{%- endif %}
    {{child_insts(node)|indent}}

{%- if has_coverage %}
    {{coverage_insts(node)|indent}}
{%- endif %}

    {{function_new(node)|indent}}

{%- if has_coverage %}
    {{coverage_function_insts(node)|indent}}
{%- endif %}

    {{function_build(node)|indent}}
endclass : {{get_class_name(node)}}
{% endif -%}
{%- endmacro %}


//------------------------------------------------------------------------------
// Child instances
//------------------------------------------------------------------------------
{% macro child_insts(node) -%}
{% for field in node.fields()|reverse -%}
{%- if is_field_reserved(field) %}
     uvm_reg_field {{get_inst_name(field)}};
{%- else %}
rand uvm_reg_field {{get_inst_name(field)}};
{%- endif -%}
{%- endfor %}
{%- endmacro %}

//------------------------------------------------------------------------------
// Coverage instances
//------------------------------------------------------------------------------
{% macro coverage_insts(node) %}
// Covergroup
covergroup cg_vals;
{%- for field in node.fields()|reverse -%}
{%- if not is_field_reserved(field) %}
    {{get_inst_name(field)}} : coverpoint {{get_inst_name(field)}}.value[{{get_field_cov_range(field)}}];
{%- endif -%}
{%- endfor %}
endgroup
{%- endmacro %}

//------------------------------------------------------------------------------
// Coverage function instances
//------------------------------------------------------------------------------
{% macro coverage_function_insts(node) %}
// Function: sample_values
virtual function void sample_values();
    super.sample_values();
    if (get_coverage(UVM_CVR_FIELD_VALS))
       cg_vals.sample();
endfunction

// Function: sample
// This method is automatically invoked by the register abstraction class
// whenever it is read or written with the specified ~data~
// via the specified address ~map~
protected virtual function void sample(uvm_reg_data_t data,
                                       uvm_reg_data_t byte_en,
                                       bit is_read,
                                       uvm_reg_map map);
    super.sample(data,byte_en,is_read,map);   
    
    foreach (m_fields[i])
       m_fields[i].value = ((data >> m_fields[i].get_lsb_pos()) &
                            ((1 << m_fields[i].get_n_bits()) - 1));
 
    sample_values();
endfunction
{%- endmacro %}

//------------------------------------------------------------------------------
// new() function
//------------------------------------------------------------------------------
{% macro function_new(node) -%}
// Function: new
function new(string name = "{{get_class_name(node)}}");
  {%- if has_coverage %}
    super.new(name, {{node.get_property('regwidth')}}, build_coverage(UVM_CVR_FIELD_VALS));
    add_coverage(build_coverage(UVM_CVR_FIELD_VALS));
    if(has_coverage(UVM_CVR_FIELD_VALS)) begin
       cg_vals = new();
       cg_vals.set_inst_name(name);
    end  
  {%- else %}
    super.new(name, {{node.get_property('regwidth')}}, UVM_NO_COVERAGE);
  {%- endif %}
endfunction : new
{%- endmacro %}


//------------------------------------------------------------------------------
// build() function
//------------------------------------------------------------------------------
{% macro function_build(node) -%}
// Function: build
virtual function void build();
    {%- for field in node.fields()|reverse %}
    {%- if use_uvm_factory %}
    this.{{get_inst_name(field)}} = uvm_reg_field::type_id::create("{{get_inst_name(field)}}");
    {%- else %}
    this.{{get_inst_name(field)}} = new("{{get_inst_name(field)}}");
    {%- endif %}
    {%- if is_field_reserved(field) == False %}
    this.{{get_inst_name(field)}}.configure( 
                          .parent(this),
                          .size({{field.width}}),
                          .lsb_pos({{field.lsb}}),
                          .access("{{get_field_access(field)}}"),
                          .volatile({{field.is_volatile|int}}),
                          .reset({{field.width}}{{"'h%x" % field.get_property('reset',default=0)}}),
                          .has_reset(1),
                          .is_rand(1),
                          .individually_accessible(0));
    {%- else -%}
    {% endif %}
    {% endfor %}
endfunction : build
{%- endmacro %}


//------------------------------------------------------------------------------
// build() actions for uvm_reg instance (called by parent)
//------------------------------------------------------------------------------
{% macro build_instance(node) -%}
{%- if node.is_array %}
foreach(this.{{get_inst_name(node)}}[{{utils.array_iterator_list(node)}}]) begin
    {%- if use_uvm_factory %}
    this.{{get_inst_name(node)}}{{utils.array_iterator_suffix(node)}} = {{get_class_name(node)}}::type_id::create($sformatf("{{get_inst_name(node)}}{{utils.array_suffix_format(node)}}", {{utils.array_iterator_list(node)}}));
    {%- else %}
    this.{{get_inst_name(node)}}{{utils.array_iterator_suffix(node)}} = new($sformatf("{{get_inst_name(node)}}{{utils.array_suffix_format(node)}}", {{utils.array_iterator_list(node)}}));
    {%- endif %}
    this.{{get_inst_name(node)}}{{utils.array_iterator_suffix(node)}}.configure(this);
    {{add_hdl_path_slices(node, get_inst_name(node) + utils.array_iterator_suffix(node))|trim|indent}}
    this.{{get_inst_name(node)}}{{utils.array_iterator_suffix(node)}}.build();
    this.default_map.add_reg(this.{{get_inst_name(node)}}{{utils.array_iterator_suffix(node)}}, {{get_array_address_offset_expr(node)}});
end
{%- else %}
{%- if use_uvm_factory %}
this.{{get_inst_name(node)}} = {{get_class_name(node)}}::type_id::create("{{get_inst_name(node)}}");
{%- else %}
this.{{get_inst_name(node)}} = new("{{get_inst_name(node)}}");
{%- endif %}
this.{{get_inst_name(node)}}.configure(this);
{{add_hdl_path_slices(node, get_inst_name(node))|trim}}
this.{{get_inst_name(node)}}.build();
this.default_map.add_reg(.rg(this.{{get_inst_name(node)}}), .offset({{get_address_width(node)}}{{"'h%x"%node.raw_address_offset}}), .rights("{{get_reg_access(node)}}"));
{% endif %}
{%- endmacro %}

//------------------------------------------------------------------------------
// Load HDL path slices for this reg instance
//{% macro add_hdl_path_slices_old(node, inst_ref) -%}
//{%- if node.get_property('hdl_path') %}
//this.{{inst_ref}}.add_hdl_path_slice("{{node.get_property('hdl_path')}}", -1, -1);
//{%- endif -%}
//
//{%- if node.get_property('hdl_path_gate') %}
//this.{{inst_ref}}.add_hdl_path_slice("{{node.get_property('hdl_path_gate')}}", -1, -1, 0, "GATE");
//{%- endif -%}
//{%- endmacro %}
//------------------------------------------------------------------------------
{% macro add_hdl_path_slices(node, inst_ref) -%}
{%- for field in node.fields()|reverse %}
{%- if field.get_property('hdl_path_slice') is none -%}
{%- elif field.get_property('hdl_path_slice')|length == 1 %}
this.{{inst_ref}}.add_hdl_path_slice(.name("{{field.get_property('hdl_path_slice')[0]}}"), .offset({{field.lsb}}), .size({{field.width}}));
{%- elif field.get_property('hdl_path_slice')|length == field.width %}
{%- for slice in field.get_property('hdl_path_slice') %}
{%- if field.msb > field.lsb %}
this.{{inst_ref}}.add_hdl_path_slice("{{slice}}", {{field.msb - loop.index0}}, 1);
{%- else %}
this.{{inst_ref}}.add_hdl_path_slice("{{slice}}", {{field.msb + loop.index0}}, 1);
{%- endif %}
{%- endfor %}
{%- endif %}
{%- endfor -%}

{%- for field in node.fields()|reverse %}
{%- if field.get_property('hdl_path_gate_slice') is none -%}
{%- elif field.get_property('hdl_path_gate_slice')|length == 1 %}
{{inst_ref}}.add_hdl_path_slice("{{field.get_property('hdl_path_gate_slice')[0]}}", {{field.lsb}}, {{field.width}}, 0, "GATE");
{%- elif field.get_property('hdl_path_gate_slice')|length == field.width %}
{%- for slice in field.get_property('hdl_path_gate_slice') %}
{%- if field.msb > field.lsb %}
{{inst_ref}}.add_hdl_path_slice("{{slice}}", {{field.msb - loop.index0}}, 1, 0, "GATE");
{%- else %}
{{inst_ref}}.add_hdl_path_slice("{{slice}}", {{field.msb + loop.index0}}, 1, 0, "GATE");
{%- endif %}
{%- endfor %}
{%- endif %}
{%- endfor %}
{%- endmacro %}
