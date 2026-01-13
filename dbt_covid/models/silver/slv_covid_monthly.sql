WITH
    new_deaths_month AS (
        SELECT
            TRIM(geography) AS code,
            TO_DATE(date, 'MON-YY') AS date,
            CAST(new_deaths_per_month_count as FLOAT)
        FROM {{ ref('brz__new_deaths_per_month') }}

    ),
    new_cases_month AS (
        SELECT
            TRIM(geography) AS code,
            TO_DATE(date, 'MON-YY') AS date,
            CAST(new_cases_per_month_count as FLOAT)
        FROM {{ ref('brz__new_cases_per_month') }}
    )

SELECT
    c.code,
    c.date,
    c.new_cases_per_month_count,
    d.new_deaths_per_month_count
FROM new_cases_month c
LEFT JOIN new_deaths_month d
    ON c.code = d.code AND c.date = d.date