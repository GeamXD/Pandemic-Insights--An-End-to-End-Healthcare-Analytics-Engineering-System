SELECT
    geography,
    date,
    count as new_deaths_per_month_count,
    CURRENT_TIMESTAMP as read_timestamp
FROM {{ ref('stg_covid__new_deaths_per_month') }}