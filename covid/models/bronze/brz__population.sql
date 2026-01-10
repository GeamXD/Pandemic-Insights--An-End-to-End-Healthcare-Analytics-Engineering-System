SELECT
    geography,
    indicator as population_indicator,
    count     as population_value,
    CURRENT_TIMESTAMP as read_timestamp
FROM {{ ref('stg_raw_covid__population') }}