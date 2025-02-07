with base as (

    select * 
    from {{ ref('stg_pardot__email_template_tmp') }}

),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_pardot__email_template_tmp')),
                staging_columns=get_email_template_columns()
            )
        }}
        
    from base
    where not coalesce(_fivetran_deleted, false)
),

final as (
    
    select 
        /* primary key, schema specific id, schema id, extracted business unit */
        {{generate_pardot_identifiers('id')}}
        
        /* attributes */
        name as email_template_name,
        subject as email_subject,
        tag_replacement_language,
        type as email_type,
        text_message,
        html_message,
        is_auto_responder_email,
        is_drip_email,
        is_list_email,
        is_one_to_one_email,
        
        /* timestamps */
        created_at,
        updated_at,
        _fivetran_deleted,
        _fivetran_synced,
        
        /* foreign keys */
        {{ generate_pardot_surrogate_key('campaign_id') }} as campaign_id,
        {{ generate_pardot_surrogate_key('created_by_id') }} as created_by_id,
        {{ generate_pardot_surrogate_key('updated_by_id') }} as updated_by_id,
        {{ generate_pardot_surrogate_key('folder_id') }} as folder_id,
        {{ generate_pardot_surrogate_key('tracker_domain_id') }} as tracker_domain_id
        
    from fields
)

select * from final