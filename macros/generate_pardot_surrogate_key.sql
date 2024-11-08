{% macro generate_pardot_surrogate_key(pre_union_primary_key) %}

    {{ dbt_utils.generate_surrogate_key([ var('source_schema'), pre_union_primary_key]) }}

{% endmacro %}