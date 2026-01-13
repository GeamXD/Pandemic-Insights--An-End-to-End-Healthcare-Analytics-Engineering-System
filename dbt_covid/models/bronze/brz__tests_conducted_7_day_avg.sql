SELECT
    geography,
    date,
    indicator as test_indicator,
    count as test_count,
    CURRENT_TIMESTAMP as read_timestamp
FROM {{ ref('stg_covid__tests_conducted_7_day_avg') }}