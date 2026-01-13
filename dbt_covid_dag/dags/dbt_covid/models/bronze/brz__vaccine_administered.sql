SELECT
    geography,
    indicator as vaccine_indicator,
    count as no_of_people_vaccinated,
    CURRENT_TIMESTAMP as read_timestamp
FROM {{ ref('stg_covid__vaccine_administered') }}