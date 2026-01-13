WITH new_deaths_7_avg AS (
        SELECT
            TRIM(geography) as code,
            CAST(date as DATE) as date,
            CAST(new_deaths_7_day_avg AS FLOAT64) as new_deaths_7_day_avg
        FROM {{ ref('brz__new_deaths_7_day_avg') }}
        WHERE new_deaths_7_day_avg is not null and geography is not null
),
new_cases_7_avg AS (
        SELECT
            TRIM(geography) as code,
            CAST(date as DATE) as date,
            CAST(new_cases_7day_avg AS FLOAT64) as new_cases_7day_avg
        FROM {{ ref('brz__new_cases_7day_avg') }}
        WHERE new_cases_7day_avg is not null and geography is not null
),
 stringency_index AS (
    SELECT
        TRIM(geography) as code,
        CAST(date as DATE) as date,
        CAST(stringency_index AS FLOAT64) as stringency_index
    FROM {{ ref('brz__stringency_index') }}
),
tests_conducted AS (
    SELECT
        TRIM(geography) as code,
        CAST(date as DATE) as date,
        COALESCE(CAST(NULLIF(test_count, 'Null') AS FLOAT64), 0) as test_count
    FROM {{ ref('brz__tests_conducted_7_day_avg') }}
)

SELECT
    c.code,
    c.date,

    c.new_cases_7day_avg,
    d.new_deaths_7_day_avg,
    s.stringency_index,
    t.test_count

FROM new_cases_7_avg c
LEFT JOIN new_deaths_7_avg d
    ON c.code = d.code AND c.date = d.date
LEFT JOIN stringency_index s
    ON c.code = s.code AND c.date = s.date
LEFT JOIN tests_conducted t
    ON c.code = t.code AND c.date = t.date