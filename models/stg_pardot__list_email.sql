

with base as (

    select
        _dbt_source_relation,
        id,
        campaign_id,
        created_by_id,
        updated_by_id,
        email_template_id,
        tracker_domain_id,
        html_message,
        operational_email,
        name,
        subject,
        client_type,
        sent_at,
        created_at,
        updated_at,
        _fivetran_synced,
        text_message,
        is_sent,
        is_paused,
        is_deleted
        
    from {{ ref('stg_pardot__list_email_tmp') }}
),

fields as (

    select 
        _dbt_source_relation,
        id,
        campaign_id,
        created_by_id,
        updated_by_id,
        email_template_id,
        tracker_domain_id,
        html_message,
        operational_email,
        name,
        subject,
        client_type,
        sent_at,
        created_at,
        updated_at,
        _fivetran_synced,
        text_message,
        is_sent,
        is_paused,
        
        {{generate_pardot_identifiers('id')}}
        
        is_deleted
    
    from base

),

seed_pardot_business_unit as (

    select 
        * 
    
    from {{ ref('seed_salesforce__d12_codes')}}

),

seed__pardot__list_email_audience_segments as (
    select * 
    from {{ ref('seed__pardot__list_email_audience_segments')}}
),


list_emails_joined as (

    select 
        fields.*,
        seed_pardot_business_unit.mass_market_abbreviation,
        seed_pardot_business_unit.pardot_business_unit_abbreviation,

        /* basics - used by both legacy mmus tracking and new cross-market tracking */
        sent_at as list_email_sent_at,
        {{fiscal_year('list_email_sent_at','list_email_sent')}},
        name as list_email_name,

        /* split list email name to parts - also used by both tracking formats*/
        {% set list_email_name_parts = range(1, 9) %}
        
        {% for list_email_name_part in list_email_name_parts %}
            nullif(
                replace(
                    split_part(
                        replace(name, '(', ' - '), 
                        ' - ', 
                        {{ list_email_name_part }}),
                    ')', 
                    ''
                ),
                '' 
            ) as list_email_name_part_{{ list_email_name_part }},
        {% endfor %}
        
        case when list_email_name ilike any ('%test%') then true else false end as is_test,

        /* List email attributes - used by both */
        subject as list_email_subject,
        text_message as list_email_message_text,
        client_type as list_email_client_type,
        
        is_deleted as is_deleted_list_email,
        is_paused as is_paused_list_email,
        is_sent as is_sent_list_email,

        /* Timestamps - used by both */
        created_at as created_timestamp,
        updated_at as updated_timestamp,
        _fivetran_synced
    
    from fields
    
    left join seed_pardot_business_unit using (pardot_business_unit_abbreviation)

),

/* legacy MMUS-only logic, prior to introduction of global email URL builder. Keeping in this CTE for historical reference */

mmus_enhanced_pre_fy25 as (
    
    select 
    *,
        case
            when try_cast(list_email_name_part_1 as integer) >= 2022
            then true
            else false
        end as is_mmus_formated_list_email_name,

        /* natural key */
        /* cleans list email name month names and special characters to produce uniform coding in the style jan01a */
        {% set month_abbreviations = {
            'january': 'jan',
            'february': 'feb',
            'march': 'mar',
            'april': 'apr',
            'may': 'may',
            'june': 'jun',
            'july': 'jul',
            'august': 'aug',
            'september': 'sep',
            'october': 'oct',
            'november': 'nov',
            'december': 'dec'
        }
        %}

        case 
            {% for month_full, month_abbreviated in month_abbreviations.items() %}
            when list_email_name_part_2 ilike '%{{ month_full }}%' 
                then regexp_replace(
                    list_email_name_part_2,
                    '{{ month_full }}', 
                    '{{ month_abbreviated }}')
            {% endfor %}
            else list_email_name_part_2
        end as mmus_pre_fy25_clean_month_names,
        left(upper(regexp_replace(mmus_pre_fy25_clean_month_names, '[# ]', '')),6) as mmus_pre_fy25_list_email_name_internal_id,


        list_email_name_part_1 as mmus_pre_fy25_list_email_name_year,
        mass_market_abbreviation||list_email_sent_fiscal_year||mmus_pre_fy25_list_email_name_internal_id as mmus_pre_fy25_list_email_natural_key,

        /* derive list email type from split part 3 */
        list_email_name_part_4 as mmus_pre_fy25_list_email_name_parsed_topic,

        /* list email segment - special logic to extract conformed attribute from name */
        {% set segment_keywords = {
            '%all%engaged%': 'All Engaged',
            '%emergency%': 'Emergency',
            '%midlevel%': 'Midlevel',
            '%ml%': 'Midlevel',
            'rai': 'RAI',
            '%sustainers%': 'Sustainers',
            '%urgents%': 'Urgents',
            '%daf%': 'DAF',
            '%planned%giving%': 'Planned Giving',
        } %}

        {% set status_keywords = {
            '%prospects%': 'Prospects',
            '%prospects%': 'Currents',
            '%active%': 'Active',
            '%lapsed%': 'Lapsed',
        } %}

        {% set type_keywords = {
            '%fundraising%': 'Fundraising',
            '%cultivation%': 'Cultivation',
            '%advocacy%': 'Advocacy',
            '%engagement%': 'Engagement'
        } %}

        /* cleaned segment value extracted from list email name */
        case
        {% for segment_keyword, segment_conformed in segment_keywords.items() %}
            when list_email_name ilike '{{ segment_keyword }}' then '{{ segment_conformed }}'
        {% endfor %}
            else null
        end as mmus_pre_fy25_list_email_keyword_segment,

        case
        {% for status_keyword, status_conformed in status_keywords.items() %}
            when list_email_name ilike '{{ status_keyword }}' then '{{ status_conformed }}'
        {% endfor %}
            else null
        end as mmus_pre_fy25_list_email_keyword_status,

        case
        {% for type_keyword, type_conformed in type_keywords.items() %}
            when list_email_name ilike '{{ type_keyword }}' then '{{ type_conformed }}'
        {% endfor %}
            else null
        end as mmus_pre_fy25_list_email_keyword_type,

        /* in which parsed string the keyword is found */
        {% set list_email_name_segment_part_numbers = range(4, 9) %}
        case
            {%- for list_email_name_part_number in list_email_name_segment_part_numbers %}
            when list_email_name_part_{{ list_email_name_part_number }} 
                ilike any (
                    {%- for keyword in segment_keywords.keys() %}
                    '{{ keyword }}'{% if not loop.last %},{% endif %}
                    {%- endfor -%}
                )
            then list_email_name_part_{{ list_email_name_part_number }}
            {%- endfor %}
            else null
        end as mmus_pre_fy25_segment_keyword_found_string,
        
        /* in which parsed name part the keyword is found */
       case
            {% for list_email_name_part_number in list_email_name_segment_part_numbers %}
            when list_email_name_part_{{ list_email_name_part_number }} 
                ilike any (
                    {%- for keyword in segment_keywords.keys() %}
                    '{{ keyword }}'{% if not loop.last %},{% endif %}
                    {%- endfor -%}
                )
            then 'list_email_name_part_{{ list_email_name_part_number }}'
            {% endfor %}
            else null
        end as mmus_pre_fy25_segment_keyword_found_in_list_email_name_part
    
    from list_emails_joined

),

mm_cross_market_list_emails_tracking as ( -- An email specific URL builder was rolled out globally in late FY25, with full adoption across markets from FY26. See https://theirc.github.io/URLBuilder/#emailUrlGenPage
    
    select
        *,

        case 
            when list_email_name_part_1 ilike 'FY%'
            and character_length(list_email_name_part_1) = 4
            then upper(list_email_name_part_1)
            else null
        end as list_email_fiscal_year,

        /* Parsing part 2 of the list email name into component parts to enable filters/group bys on Power BI reports
        
        Example Dec01MLM needs to be broken up further to show month_abbreviation (Dec), email version number (01) and email segment code (MLM) */

        /* Parsing email month_abbreviated */

        case 
            when list_email_name_part_1 ilike 'FY%'
            and character_length(list_email_name_part_2) in (8,9)
            then left(list_email_name_part_2,3)
        else null
        end as list_email_month_abbreviated,

        /* Parsing email version number */
        case 
            when list_email_name_part_1 ilike 'FY%'
            and character_length(list_email_name_part_2) in (8,9)
            then substring(list_email_name_part_2, 4, 2) -- Extract positions 4-5 which are always two numbers for version number as per URL builder form
            else null
        end as list_email_version_number,

        /* Parsing audience segment code */

        case 
            when list_email_name_part_1 ilike 'FY%'
            and character_length(list_email_name_part_2) in (8,9)
            then substring(list_email_name_part_2, 6,3) -- Extract positions 6-8 which are always three characters for audience segment code as per URL builder form
        else null
        end as list_email_audience_segment_code,
        
        /* Parsing additional testing variants (non mandatory field in Email URL Builder) */

        case 
            when list_email_name_part_1 ilike 'FY%'
                and character_length(list_email_name_part_2) = 9
            then right(list_email_name_part_2, 1) -- Extract position 9 which is the testing variant when present as per URL builder form
            else null
        end as list_email_test_variant,

        /* Flag to check that emails are using latest URL builder format from late FY25/early FY26 */
        case 
            when list_email_name_part_1 ilike 'FY%' 
            and character_length(list_email_name_part_1) = 4 
            and character_length(list_email_name_part_2) in (8,9)
            and list_email_audience_segment_code is not null
            then true
            else false 
        end as is_list_email_url_builder_format,

        case 
            when list_email_name_part_1 ilike 'FY%'
            and character_length(list_email_name_part_1) = 4
            and character_length(list_email_name_part_2) in (8,9)
            then list_email_name_part_3
            else null
        end as list_email_type,


        /* Natural key components to join to donations */
        case when is_list_email_url_builder_format then
            upper(list_email_month_abbreviated)||upper(list_email_version_number)||upper(list_email_audience_segment_code)||coalesce(list_email_test_variant,'')
        else null
        end as list_email_name_internal_id,

        case when is_list_email_url_builder_format then
            mass_market_abbreviation||list_email_fiscal_year||list_email_name_internal_id
        else null
        end as list_email_natural_key

        from mmus_enhanced_pre_fy25
)


select 
mm_cross_market_list_emails_tracking.*,
seed__pardot__list_email_audience_segments.audience_segment_name as list_email_audience_segment_name
from mm_cross_market_list_emails_tracking
left join seed__pardot__list_email_audience_segments
on mm_cross_market_list_emails_tracking.list_email_audience_segment_code = seed__pardot__list_email_audience_segments.audience_segment_code