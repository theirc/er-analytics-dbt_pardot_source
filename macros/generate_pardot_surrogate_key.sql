{% macro generate_pardot_surrogate_key(pre_union_primary_key, model_name=None) %}
    {% set model = model_name if model_name else this.name.split('__')[-1] %}

    {% set source_schema = "split_part(_dbt_source_relation, '.', 1) || '.' || split_part(_dbt_source_relation, '.', 2)" %}

    {{ source_schema }} as {{ model }}_source_schema,
    {{ dbt_utils.generate_surrogate_key([source_schema, pre_union_primary_key]) }}

{% endmacro %}