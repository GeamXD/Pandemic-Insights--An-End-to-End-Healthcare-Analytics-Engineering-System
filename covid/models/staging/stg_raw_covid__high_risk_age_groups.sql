SELECT
    *
FROM {{ source('raw_covid', 'high_risk_age_groups') }}