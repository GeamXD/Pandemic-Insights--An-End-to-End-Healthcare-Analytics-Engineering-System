SELECT
    geography,
    indicator AS dm_indicator,
    count     AS pct_diabetes,
    CURRENT_TIMESTAMP as read_timestamp
FROM {{ ref('stg_covid__diabetes_prevalence') }}
