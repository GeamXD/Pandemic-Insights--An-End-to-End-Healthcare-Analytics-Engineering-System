SELECT
    geography,
    indicator as gdp_indicator,
    count     as gdp,
    CURRENT_TIMESTAMP as read_timestamp
FROM {{ ref('stg_raw_covid__gross_domestic_product') }}