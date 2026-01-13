SELECT
    geography,
    indicator AS cvs_death_rate_indicator,
    count     AS cvs_death_rate_per_ten_thousand,
    CURRENT_TIMESTAMP as read_timestamp
FROM {{ ref('stg_covid__death_rate_from_cardiovascular_disease') }}