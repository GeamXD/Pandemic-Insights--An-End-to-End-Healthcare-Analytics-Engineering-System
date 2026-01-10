SELECT
    *
FROM {{ source('raw_covid', 'death_rate_from_cardiovascular_disease') }}