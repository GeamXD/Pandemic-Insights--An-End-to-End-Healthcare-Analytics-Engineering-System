SELECT
    geography,
    date,
    indicator as new_cases_per_month_indicator,
    count     as new_cases_per_month_count,
    CURRENT_TIMESTAMP as read_timestamp
FROM {{ ref('stg_raw_covid__new_cases_per_month') }}