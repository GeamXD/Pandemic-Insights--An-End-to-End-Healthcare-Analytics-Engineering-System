SELECT
    *
FROM {{ source('raw_covid', 'gross_domestic_product') }}