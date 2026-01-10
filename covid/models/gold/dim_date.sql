WITH months AS (
    SELECT explode(
        sequence(
            to_date('2019-01-01'),
            to_date('2021-12-01'),
            interval 1 month
        )
    ) AS month_start_date
)
SELECT
    CAST(date_format(month_start_date, 'yyyyMM') AS INT) AS date_key,
    year(month_start_date) AS year,
    date_format(month_start_date, 'MMMM') AS month_name,
    date_format(month_start_date, 'MMM') AS month_short_name,
    CONCAT('Q', quarter(month_start_date)) AS quarter,
    CONCAT(year(month_start_date), '-Q', quarter(month_start_date)) AS year_quarter,
    month_start_date AS date
FROM months;