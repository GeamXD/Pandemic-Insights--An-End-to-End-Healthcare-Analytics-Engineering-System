SELECT
    geography,
    indicator as median_age_life_expectancy_indicator,
    count     as median_age_life_expectancy_value,
    CURRENT_TIMESTAMP as read_timestamp
FROM {{ ref('stg_raw_covid__median_age_and_life_expectancy') }}