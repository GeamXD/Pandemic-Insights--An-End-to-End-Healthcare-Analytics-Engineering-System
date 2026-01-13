# This loops through every CSV and uploads it to BigQuery
for file in data/raw/*.csv; do
    # Extract filename without extension for the table name
    table_name=$(basename "$file" .csv)

    # Upload to BigQuery (autodetects schema)
    bq load --autodetect --source_format=CSV healthcare-analytics-471307:covid.$table_name "$file"
done