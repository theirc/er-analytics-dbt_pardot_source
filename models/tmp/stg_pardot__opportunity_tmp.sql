{{
    fivetran_utils.union_data(
        table_identifier='opportunity', 
        database_variable='pardot_database', 
        schema_variable='pardot_schema', 
        default_database=target.database,
        default_schema='pardot',
        default_variable='opportunity',
        union_schema_variable='pardot_union_schemas',
        union_database_variable='pardot_union_databases'
    )
}}