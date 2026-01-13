SELECT
    geography,
    date,
    indicator as new_deaths_7_day_avg_indicator,
    count     as new_deaths_7_day_avg,
    CURRENT_TIMESTAMP as read_timestamp
FROM {{ ref('stg_covid__new_deaths_7_day_avg') }}