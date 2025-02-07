{% docs _fivetran_synced %}
The timestamp of when a record was last synced by Fivetran.
{% enddocs %}

{% docs _fivetran_deleted %}
Boolean representing whether the record has been deleted in the source system.
{% enddocs %}

{% docs _dbt_source_relation %}
Created by the Fivetran union schema variables & macro, this column indicated the source table used in a post-union table
{% enddocs %}

{% docs email_template_id %}
The Account Engagement ID of the email template.
{% enddocs %}

{% docs campaign_id %}
The ID of the campaign associated with this email template.
{% enddocs %}

{% docs created_by_id %}
The ID of the user who created the email template.
{% enddocs %}

{% docs updated_by_id %}
The ID of the user who last updated the email template.
{% enddocs %}

{% docs created_at %}
Timestamp when the email template was created.
{% enddocs %}

{% docs updated_at %}
Timestamp when the email template was last updated.
{% enddocs %}

{% docs is_auto_responder_email %}
Flag indicating if the template is available for use as an auto response from form submissions.
{% enddocs %}

{% docs is_drip_email %}
Flag indicating if the template is available for use in engagement programs.
{% enddocs %}

{% docs is_list_email %}
Flag indicating if the template is available for use in list emails.
{% enddocs %}

{% docs is_one_to_one_email %}
Flag indicating if the template is available for use in one-to-one emails.
{% enddocs %}

{% docs name %}
The name of the email template.
{% enddocs %}

{% docs subject %}
The subject line of the email message.
{% enddocs %}

{% docs tag_replacement_language %}
The language used for variable tag replacements in the template.
{% enddocs %}

{% docs type %}
The type classification of the email template.
{% enddocs %}

{% docs text_message %}
The plain text version of the email content.
{% enddocs %}

{% docs html_message %}
The HTML version of the email content.
{% enddocs %}

{% docs folder_id %}
The ID of the folder containing this template.
{% enddocs %}

{% docs tracker_domain_id %}
The ID of the tracking domain used for this template.
{% enddocs %}

{% docs email_template_name %}
The name of the email template.
{% enddocs %}

{% docs email_subject %}
The subject line of the email message.
{% enddocs %}

{% docs email_type %}
The type classification of the email template.
{% enddocs %}