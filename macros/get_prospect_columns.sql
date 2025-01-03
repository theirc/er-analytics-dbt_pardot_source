{% macro get_prospect_columns() %}

{% set columns = [
    {"name": "_dbt_source_relation", "datatype": dbt.type_string()},
    {"name": "_fivetran_deleted", "datatype": "boolean"},
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "address_one", "datatype": dbt.type_string()},
    {"name": "address_two", "datatype": dbt.type_string()},
    {"name": "annual_revenue", "datatype": dbt.type_string()},
    {"name": "campaign_id", "datatype": dbt.type_int()},
    {"name": "city", "datatype": dbt.type_string()},
    {"name": "comments", "datatype": dbt.type_string()},
    {"name": "company", "datatype": dbt.type_string()},
    {"name": "country", "datatype": dbt.type_string()},
    {"name": "created_at", "datatype": dbt.type_timestamp()},
    {"name": "crm_account_fid", "datatype": dbt.type_string()},
    {"name": "crm_contact_fid", "datatype": dbt.type_string()},
    {"name": "crm_last_sync", "datatype": dbt.type_timestamp()},
    {"name": "crm_lead_fid", "datatype": dbt.type_string()},
    {"name": "crm_owner_fid", "datatype": dbt.type_string()},
    {"name": "crm_url", "datatype": dbt.type_string()},
    {"name": "department", "datatype": dbt.type_string()},
    {"name": "email", "datatype": dbt.type_string()},
    {"name": "employees", "datatype": dbt.type_string()},
    {"name": "fax", "datatype": dbt.type_string()},
    {"name": "first_name", "datatype": dbt.type_string()},
    {"name": "grade", "datatype": dbt.type_string()},
    {"name": "id", "datatype": dbt.type_int()},
    {"name": "industry", "datatype": dbt.type_string()},
    {"name": "is_do_not_call", "datatype": "boolean"},
    {"name": "is_do_not_email", "datatype": "boolean"},
    {"name": "is_reviewed", "datatype": "boolean"},
    {"name": "is_starred", "datatype": "boolean"},
    {"name": "job_title", "datatype": dbt.type_string()},
    {"name": "last_activity_at", "datatype": dbt.type_timestamp()},
    {"name": "last_name", "datatype": dbt.type_string()},
    {"name": "notes", "datatype": dbt.type_string()},
    {"name": "opted_out", "datatype": "boolean"},
    {"name": "password", "datatype": dbt.type_string()},
    {"name": "phone", "datatype": dbt.type_string()},
    {"name": "prospect_account_id", "datatype": dbt.type_int()},
    {"name": "recent_interaction", "datatype": dbt.type_string()},
    {"name": "salutation", "datatype": dbt.type_string()},
    {"name": "score", "datatype": dbt.type_int()},
    {"name": "source", "datatype": dbt.type_string()},
    {"name": "state", "datatype": dbt.type_string()},
    {"name": "territory", "datatype": dbt.type_string()},
    {"name": "updated_at", "datatype": dbt.type_timestamp()},
    {"name": "user_id", "datatype": dbt.type_int()},
    {"name": "website", "datatype": dbt.type_string()},
    {"name": "years_in_business", "datatype": dbt.type_string()},
    {"name": "zip", "datatype": dbt.type_string()}
] %}

{{ return(columns) }}

{% endmacro %}
