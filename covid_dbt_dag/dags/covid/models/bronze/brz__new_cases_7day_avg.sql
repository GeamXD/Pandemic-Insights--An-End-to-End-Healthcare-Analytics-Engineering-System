SELECT
    geography,
    date,
    indicator as new_cases_7day_avg_indicator,
    count     as new_cases_7day_avg,
    CURRENT_TIMESTAMP as read_timestamp
FROM {{ ref('stg_raw_covid__new_cases_7day_avg') }}