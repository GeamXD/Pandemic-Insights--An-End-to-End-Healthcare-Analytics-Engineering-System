WITH months AS (
    SELECT month_start_date
    FROM UNNEST(
        GENERATE_DATE_ARRAY('2019-01-01', '2021-12-01', INTERVAL 1 MONTH)
    ) AS month_start_date
)

SELECT
    CAST(FORMAT_DATE('%Y%m', month_start_date) AS INT64) AS date_key,
    EXTRACT(YEAR FROM month_start_date) AS year,
    FORMAT_DATE('%B', month_start_date) AS month_name,
    FORMAT_DATE('%b', month_start_date) AS month_short_name,
    CONCAT('Q', EXTRACT(QUARTER FROM month_start_date)) AS quarter,
    CONCAT(EXTRACT(YEAR FROM month_start_date), '-Q', EXTRACT(QUARTER FROM month_start_date)) AS year_quarter,
    month_start_date AS date
FROM months