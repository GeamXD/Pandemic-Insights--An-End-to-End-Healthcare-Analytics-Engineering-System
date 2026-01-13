SELECT
    geography,
    indicator as gender,
    count     as smoking_count,
    CURRENT_TIMESTAMP as read_timestamp
FROM {{ ref('stg_covid__smoking') }}