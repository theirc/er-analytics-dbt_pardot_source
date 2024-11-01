{% macro generate_pardot_surrogate_key(pre_union_primary_key)%}
split_part(_dbt_source_relation, '.', 1) ||'.'|| split_part(_dbt_source_relation, '.', 2) as source_schema,
{{ dbt_utils.generate_surrogate_key(['source_schema', pre_union_primary_key]) }}
{% endmacro %}