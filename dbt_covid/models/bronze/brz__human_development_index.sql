SELECT
    geography,
    indicator as hdi_indicator,
    count     as hum_dev_index,
    CURRENT_TIMESTAMP as read_timestamp
FROM {{ ref('stg_covid__human_development_index') }}