{{
    fivetran_utils.union_data(
        table_identifier='prospect', 
        database_variable='pardot_database', 
        schema_variable='pardot_schema', 
        default_database=target.database,
        default_schema='pardot',
        default_variable='prospect',
        union_schema_variable='pardot_union_schemas',
        union_database_variable='pardot_union_databases'
    )
}}