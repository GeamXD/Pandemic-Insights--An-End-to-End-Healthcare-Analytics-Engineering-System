# 1. Create the directory if it doesn't exist
mkdir -p dbt_covid/models/staging

# 2. Define the list of tables
tables=(
"death-rate-from-cardiovascular-disease"
"diabetes-prevalence"
"gross-domestic-product"
"high-risk-age-groups"
"hopsital-beds-and-handwashing"
"human-development-index"
"median-age-and-life-expectancy"
"new-cases-7day-avg"
"new-cases-per-month"
"new-deaths-7-day-avg"
"new-deaths-per-month"
"population"
"smoking"
"stringency-index"
"tests-conducted-7-day-avg"
"vaccine-administered"
)

# 3. Loop through and generate files
for table in "${tables[@]}"; do
    # Convert hyphens to underscores for the filename
    safe_name=$(echo "$table" | tr '-' '_')
    filename="dbt_covid/models/staging/stg_covid__${safe_name}.sql"

    echo "Generating $filename..."

    # Write the SQL content
    cat <<EOT > "$filename"
with source as (

    select * from {{ source('covid', '$table') }}

),

renamed as (

    select
        -- TODO: add specific column selection here
        *

    from source

)

select * from renamed
EOT
done

echo "Done! 16 files created in dbt_covid/models/staging/"