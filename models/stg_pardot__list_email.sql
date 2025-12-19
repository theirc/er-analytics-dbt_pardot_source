

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
        *
    
    from fields
    
    left join seed_pardot_business_unit using (pardot_business_unit_abbreviation)

),


mmus_enhanced_pre_fy25 as (
    
    select 
        /* primary key, schema specific id, schema id, extracted business unit */
        list_email_id,
        list_email_source_schema,
        pardot_business_unit_abbreviation,
        mass_market_abbreviation,
        list_email_schema_specific_id,
        
        /* basics */
        sent_at as list_email_sent_at,
        {{fiscal_year('list_email_sent_at','list_email_sent')}},
        name as list_email_name,

        /* split list email name to parts */
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
        
        /* validate whether the email name has mmus formatting, defined: first split part of the name is a year on or after 2022 */    
        case
            when try_cast(list_email_name_part_1 as integer) >= 2022
            then true
            else false
        end as is_mmus_formated_list_email_name,
        case when list_email_name ilike any ('%test%') then true else false end as is_test,

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
        end as clean_month_names,
        left(upper(regexp_replace(clean_month_names, '[# ]', '')),6) as list_email_name_internal_id,


        list_email_name_part_1 as list_email_name_year,
        mass_market_abbreviation||list_email_sent_fiscal_year||list_email_name_internal_id as list_email_natural_key,


        /* derive list email type from split part 3 */
        list_email_name_part_4 as list_email_name_parsed_topic,

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
        end as list_email_keyword_segment,

        case
        {% for status_keyword, status_conformed in status_keywords.items() %}
            when list_email_name ilike '{{ status_keyword }}' then '{{ status_conformed }}'
        {% endfor %}
            else null
        end as list_email_keyword_status,

        case
        {% for type_keyword, type_conformed in type_keywords.items() %}
            when list_email_name ilike '{{ type_keyword }}' then '{{ type_conformed }}'
        {% endfor %}
            else null
        end as list_email_keyword_type,

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
        end as segment_keyword_found_string,
        
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
        end as segment_keyword_found_in_list_email_name_part,

        /* list email attributes */
        subject as list_email_subject,
        text_message as list_email_message_text,
        client_type as list_email_client_type,
        
        is_deleted as is_deleted_list_email,
        is_paused as is_paused_list_email,
        is_sent as is_sent_list_email,

        /* timestamps */
        created_at as created_timestamp,
        updated_at as updated_timestamp,
        _fivetran_synced
    
    from list_emails_joined

),

global_list_emails_standard as ( -- An email specific URL builder was rolled out globally in late FY25, with full adoption across markets from FY26. See https://theirc.github.io/URLBuilder/#emailUrlGenPage
    
    select
        *,
        /* Parsing part 2 of the list email name into component parts to enable filters/group bys on Power BI reports
        
        Example Dec01MLM needs to be broken up further to show month_abbreviation (Dec), email version number (01) and email segment code (MLM) */

        /* Parsing email month_abbreviated */
        case 
            when list_email_name_part_1 ilike 'FY%'
            and character_length(list_email_name_part_2) in (8,9)
            then left(list_email_name_part_2,3)
        else null
        end as email_url_builder_month_abbreviated,

        /* Utilising the jinja dictionary that Tyler created in the previous CTE, to now map month abbreviations to full month name */
        case
            {% for month_full, month_abbreviated in month_abbreviations.items() %}
            when email_url_builder_month_abbreviated ilike '{{ month_abbreviated }}' then initcap('{{ month_full }}')
            {% endfor %}
        else null
        end as email_url_builder_month_full_name,

        /* Parsing email version number */
        case 
            when list_email_name_part_1 ilike 'FY%'
            and character_length(list_email_name_part_2) in (8,9)
            then substring(list_email_name_part_2, 4, 2) -- Extract positions 4-5 which are always two numbers for version number as per URL builder form
            else null
        end as email_url_builder_version_number,

        /* Parsing audience segment code */

        case 
            when list_email_name_part_1 ilike 'FY%'
            and character_length(list_email_name_part_2) in (8,9)
            then substring(list_email_name_part_2, 6,3) -- Extract positions 6-8 which are always three characters for audience segment code as per URL builder form
        else null
        end as email_url_builder_audience_segment_code,
        
        /* Parsing additional testing variants (non mandatory field in Email URL Builder) */

        case 
            when list_email_name_part_1 ilike 'FY%'
                and character_length(list_email_name_part_2) = 9
            then right(list_email_name_part_2, 1) -- Extract position 9 which is the testing variant when present as per URL builder form
            else null
        end as email_url_builder_test_variant,

        /* Flag to check that emails are using latest URL builder format from late FY25/early FY26 */
        case 
            when list_email_name_part_1 ilike 'FY%' 
            and character_length(list_email_name_part_2) in (8,9)
            and email_url_builder_audience_segment_code is not null
            then true
            else false 
        end as is_email_url_builder_format

        from mmus_enhanced_pre_fy25
)


select 
global_list_emails_standard.*,
seed__pardot__list_email_audience_segments.audience_segment_name
from global_list_emails_standard
left join seed__pardot__list_email_audience_segments
on global_list_emails_standard.email_url_builder_audience_segment_code = seed__pardot__list_email_audience_segments.audience_segment_code