SELECT
    geography,
    date,
    count as stringency_index,
    CURRENT_TIMESTAMP as read_timestamp
FROM {{ ref('stg_covid__stringency_index') }}