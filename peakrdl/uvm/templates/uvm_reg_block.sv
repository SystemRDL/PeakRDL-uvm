{% import 'utils.sv' as utils with context %}

//------------------------------------------------------------------------------
// uvm_reg_block definition
//------------------------------------------------------------------------------
{% macro class_definition(node) -%}

{%- if has_coverage %}
//-----------------------------------------------------------------------------
// {{get_class_friendly_name(node)}}_coverage
//-----------------------------------------------------------------------------
class {{get_class_name(node)}}_coverage extends uvm_object;
{%- if use_uvm_factory %}
    `uvm_object_utils({{get_class_name(node)}}_coverage)
{% endif %}
    // Covergroup: ra_cov
    covergroup ra_cov(string name) with function sample(uvm_reg_addr_t addr, bit is_read);

       option.per_instance = 1;
       option.name = name; 

       ADDR: coverpoint addr {
        {% for child in node.children() -%}
        {%- if isinstance(child, RegNode) -%}
            bins {{get_inst_name(child)}} = { {{get_address_width(child)}}{{"'h%x"%child.raw_address_offset}} };
        {% endif -%}
        {%- endfor -%}
        }

       RW: coverpoint is_read {
        bins RD = {1};
        bins WR = {0};
        }
       
       ACCESS: cross ADDR, RW {
        {% for child in node.children() -%}
        {%- if isinstance(child, RegNode) and is_reg_access_ro(child) -%}
            ignore_bins READ_ONLY_{{get_inst_name(child)}} = binsof(ADDR) intersect { {{get_address_width(child)}}{{"'h%x"%child.raw_address_offset}} } && binsof(RW) intersect {0};
        {% endif -%}
        {%- endfor -%}
        }

    endgroup : ra_cov

    // Function: new
    function new(string name = "{{get_class_name(node)}}_coverage");
       ra_cov = new(name);
    endfunction : new

    // Function: sample
    function void sample(uvm_reg_addr_t offset, bit is_read);
       ra_cov.sample(offset, is_read);
    endfunction : sample
    
endclass : {{get_class_name(node)}}_coverage

{%- endif -%}

{%- if class_needs_definition(node) %}

//-----------------------------------------------------------------------------
// {{get_class_friendly_name(node)}}
//-----------------------------------------------------------------------------
class {{get_class_name(node)}} extends uvm_reg_block;
{%- if use_uvm_factory %}
    `uvm_object_utils({{get_class_name(node)}})
{% endif %}
    {{child_insts(node)|indent}}
    {{function_new(node)|indent}}

    {{function_build(node)|indent}}
    {% if has_coverage -%}
    {{function_sample(node)|indent}}
    {%- endif %}
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
{%- if has_coverage %}
{{get_class_name(node)}}_coverage {{get_class_name(node)}}_cg;
{% endif %}
{%- endmacro %}


//------------------------------------------------------------------------------
// new() function
//------------------------------------------------------------------------------
{% macro function_new(node) -%}
// Function: new 
function new(string name = "{{get_class_name(node)}}");
{%- if has_coverage %}
    super.new(name, build_coverage(UVM_CVR_ALL));
{%- else %}
    super.new(name);
{% endif %}
endfunction : new
{%- endmacro %}


//------------------------------------------------------------------------------
// build() function
//------------------------------------------------------------------------------
{% macro function_build(node) -%}
// Function: build
virtual function void build();
    this.default_map = create_map(.name("{{get_inst_map_name(node)}}"),
                                  .base_addr({{get_address_width(node)}}'h{{get_base_address(node)}}), 
                                  .n_bytes({{get_bus_width(node)}}), 
                                  .endian({{get_endianness(node)}}));

    this.add_hdl_path("{{node.get_property('hdl_path')}}");

    {% if has_coverage -%}
    if(has_coverage(UVM_CVR_ADDR_MAP)) begin
      {{get_class_name(node)}}_cg = {{get_class_name(node)}}_coverage::type_id::create("{{get_class_name(node)}}_cg");
      {{get_class_name(node)}}_cg.ra_cov.set_inst_name(this.get_full_name());
      void'(set_coverage(UVM_CVR_ADDR_MAP));
    end
    {% endif -%}

    {% for child in node.children() -%}
        {%- if isinstance(child, RegNode) -%}
            {{uvm_reg.build_instance(child)|indent}}
        {%- elif isinstance(child, (RegfileNode, AddrmapNode)) -%}
            {{build_instance(child)|indent}}
        {%- elif isinstance(child, MemNode) -%}
            {{uvm_reg_block_mem.build_instance(child)|indent}}
        {%- endif -%}
    {%- endfor %}
endfunction : build
{%- endmacro %}

//------------------------------------------------------------------------------
// sample() function
//------------------------------------------------------------------------------
{% macro function_sample(node) %}
// Function: sample
protected virtual function void sample(uvm_reg_addr_t offset, bit is_read, uvm_reg_map  map);
    if(get_coverage(UVM_CVR_ADDR_MAP)) begin
       if(map.get_name() == "{{get_inst_map_name(node)}}") begin
          {{get_class_name(node)}}_cg.sample(offset, is_read);
       end
    end
endfunction: sample
{% endmacro %}

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
