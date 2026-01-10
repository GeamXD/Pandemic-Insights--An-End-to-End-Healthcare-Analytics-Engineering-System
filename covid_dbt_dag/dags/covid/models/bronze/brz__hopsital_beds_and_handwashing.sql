SELECT
    geography,
    indicator as handwashing_indicator,
    count     as pct_handwashing,
    CURRENT_TIMESTAMP as read_timestamp
FROM {{ ref('stg_raw_covid__hopsital_beds_and_handwashing') }}