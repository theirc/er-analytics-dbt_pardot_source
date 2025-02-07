{% macro get_email_template_columns() %}

{% set columns = [
    {"name": "_dbt_source_relation", "datatype": dbt.type_string()},
    {"name": "_fivetran_deleted", "datatype": "boolean"},
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "id", "datatype": dbt.type_int()},
    {"name": "campaign_id", "datatype": dbt.type_int()},
    {"name": "created_by_id", "datatype": dbt.type_int()},
    {"name": "updated_by_id", "datatype": dbt.type_int()},
    {"name": "created_at", "datatype": dbt.type_timestamp()},
    {"name": "updated_at", "datatype": dbt.type_timestamp()},
    {"name": "is_auto_responder_email", "datatype": "boolean"},
    {"name": "is_drip_email", "datatype": "boolean"},
    {"name": "is_list_email", "datatype": "boolean"},
    {"name": "is_one_to_one_email", "datatype": "boolean"},
    {"name": "name", "datatype": dbt.type_string()},
    {"name": "subject", "datatype": dbt.type_string()},
    {"name": "tag_replacement_language", "datatype": dbt.type_string()},
    {"name": "type", "datatype": dbt.type_string()},
    {"name": "text_message", "datatype": dbt.type_string()},
    {"name": "html_message", "datatype": dbt.type_string()},
    {"name": "folder_id", "datatype": dbt.type_int()},
    {"name": "tracker_domain_id", "datatype": dbt.type_int()}
] %}

{{ return(columns) }}

{% endmacro %}