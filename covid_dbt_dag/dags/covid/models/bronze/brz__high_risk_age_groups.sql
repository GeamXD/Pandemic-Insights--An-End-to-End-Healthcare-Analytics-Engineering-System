SELECT
    geography,
    indicator as high_risk_age_grp_indicator,
    count     as pct_high_risk_age_grp,
    CURRENT_TIMESTAMP as read_timestamp
FROM {{ ref('stg_raw_covid__high_risk_age_groups') }}