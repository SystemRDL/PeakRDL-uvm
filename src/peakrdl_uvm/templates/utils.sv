/*
 * If node is an array, emit the array suffixes for each dimension
 * for example, a 3-dimensional array:
 *  [2][4][6]
 */
{% macro array_inst_suffix(node) -%}
    {%- if node.is_array -%}
        {%- for dim in node.array_dimensions -%}
            [{{dim}}]
        {%- endfor -%}
    {%- endif -%}
{%- endmacro %}


/*
 * If node is an array, emit a list of iterators
 * for example, a 3-dimensional array:
 *  i0, i1, i2
 */
{% macro array_iterator_list(node) -%}
    {%- if node.is_array -%}
        {%- for dim in node.array_dimensions -%}
            {{- "i%d" % loop.index0 -}}
            {%- if not loop.last %}, {% endif -%}
        {%- endfor -%}
    {%- endif -%}
{%- endmacro %}


/*
 * If node is an array, emit a list of array suffix iterators
 * for example, a 3-dimensional array:
 *  [i0][i1][i2]
 */
{% macro array_iterator_suffix(node) -%}
    {%- if node.is_array -%}
        {%- for dim in node.array_dimensions -%}
            {{- "[i%d]" % loop.index0 -}}
        {%- endfor -%}
    {%- endif -%}
{%- endmacro %}


/*
 * If node is an array, emit an array suffix format string
 * for example, a 3-dimensional array:
 *  [%0d][%0d][%0d]
 */
{% macro array_suffix_format(node) -%}
    {%- if node.is_array -%}
        {%- for _ in node.array_dimensions -%}
            {{- "[%0d]" -}}
        {%- endfor -%}
    {%- endif -%}
{%- endmacro %}
