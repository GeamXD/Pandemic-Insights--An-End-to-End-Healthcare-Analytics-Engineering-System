# COVID-19 Analytics dbt Project

## Overview

This dbt project implements a layered data transformation pipeline for COVID-19 pandemic data analysis. The project follows the medallion architecture pattern with Staging, Bronze, Silver, and Gold layers.

## Project Configuration

### Profile
- **Name**: `covid`
- **Target**: `dev` (default)
- **Database**: Google BigQuery
- **Schema**: `staging` (default)

### Model Materialization Strategy
- **Staging**: Views (lightweight, no storage)
- **Bronze**: Tables (raw data with metadata)
- **Silver**: Tables (cleaned and conformed data)
- **Gold**: Tables (dimensional models and aggregates)
- **Incremental**: Incremental updates for time-series data

## Model Layers

### 1. Staging Layer (`models/staging/`)
**Purpose**: Extract data from raw sources with minimal transformation

**Files**:
- `raw_covid.yml`: Source definitions and data quality tests
- `stg_raw_covid__*.sql`: Staging models for each data source

**Naming Convention**: `stg_raw_covid__<table_name>`

**Example**:
```sql
-- stg_raw_covid__new_cases_7day_avg.sql
SELECT *
FROM {{ source('raw_covid', 'new_cases_7day_avg') }}
```

**Data Sources** (defined in `raw_covid.yml`):
- vaccine_administered
- tests_conducted_7_day_avg
- stringency_index
- new_deaths_per_month
- new_deaths_7_day_avg
- new_cases_per_month
- new_cases_7day_avg
- human_development_index
- hopsital_beds_and_handwashing
- median_age_and_life_expectancy
- death_rate_from_cardiovascular_disease
- high_risk_age_groups
- gross_domestic_product
- smoking
- population
- diabetes_prevalence

### 2. Bronze Layer (`models/bronze/`)
**Purpose**: Store raw data with audit metadata

**Naming Convention**: `brz__<table_name>`

**Transformations**:
- Add `read_timestamp` for data lineage
- Rename columns for clarity
- Preserve original data structure

**Example**:
```sql
-- brz__new_cases_7day_avg.sql
SELECT
    geography,
    date,
    indicator as new_cases_7day_avg_indicator,
    count as new_cases_7day_avg,
    CURRENT_TIMESTAMP as read_timestamp
FROM {{ ref('stg_raw_covid__new_cases_7day_avg') }}
```

**Models** (16 total):
- brz__new_cases_7day_avg
- brz__new_deaths_7_day_avg
- brz__stringency_index
- brz__tests_conducted_7_day_avg
- brz__new_cases_per_month
- brz__new_deaths_per_month
- brz__vaccine_administered
- brz__population
- brz__diabetes_prevalence
- brz__smoking
- brz__gross_domestic_product
- brz__high_risk_age_groups
- brz__death_rate_from_cardiovascular_disease
- brz__median_age_and_life_expectancy
- brz__hopsital_beds_and_handwashing
- brz__human_development_index

### 3. Silver Layer (`models/silver/`)
**Purpose**: Clean, validate, and join data for analytics

**Naming Convention**: `slv_<domain>`

**Transformations**:
- Data type casting
- Data cleansing (TRIM, NULLIF)
- Multi-table joins
- Calculated fields

**Models**:

#### `slv_covid_daily.sql`
Daily COVID-19 metrics joined from multiple sources:
- New cases (7-day average)
- New deaths (7-day average)
- Stringency index
- Test counts

#### `slv_covid_monthly.sql`
Monthly aggregated COVID-19 data:
- New cases per month
- New deaths per month

#### `slv_geo_health.sql`
Geographic health and demographic indicators:
- Population statistics
- Diabetes prevalence
- Smoking rates
- GDP
- Age demographics
- Hospital beds
- Human development index

#### `slv_gender_health.sql`
Gender-specific health metrics for analysis.

### 4. Gold Layer (`models/gold/`)
**Purpose**: Business-ready dimensional models and ML features

**Naming Convention**: 
- `dim_<dimension>`: Dimension tables
- `fact_<fact>`: Fact tables
- `ml_<purpose>`: Machine learning features

**Models**:

#### Dimensions
**`dim_country.sql`**
- Country-level attributes
- Surrogate key: `country_key`
- Includes health indicators, demographics, HDI

**`dim_date.sql`**
- Date dimension table
- Date parts, fiscal periods, holidays

**`dim_gender.sql`**
- Gender dimension for health analysis

#### Facts
**`fact_covid_daily.sql`**
- Daily COVID-19 metrics
- Foreign keys: `country_key`, `date_key`
- Measures: cases, deaths, stringency, tests

**`fact_covid_monthly.sql`**
- Monthly aggregated COVID-19 data
- Derived from daily fact

**`fact_gender_health.sql`**
- Gender-specific health metrics

**`fact_vaccination.sql`**
- Vaccination progress tracking

#### Machine Learning Features
**`ml_features.sql`**
- Time-series features with lag calculations
- Country-level static features
- Target variables: deaths, cases
- Features:
  - cases_lag_7d
  - deaths_lag_14d
  - stringency_index and lags
  - case_fatality_rate
  - Demographics and health indicators

## Usage

### Running Models

```bash
# Run all models
dbt run

# Run specific layer
dbt run --select staging
dbt run --select bronze
dbt run --select silver
dbt run --select gold

# Run specific model and its dependencies
dbt run --select +slv_covid_daily

# Run specific model and its downstream dependencies
dbt run --select slv_covid_daily+
```

### Testing

```bash
# Run all tests
dbt test

# Test specific layer
dbt test --select staging
dbt test --select source:raw_covid

# Test specific model
dbt test --select slv_covid_daily
```

### Documentation

```bash
# Generate documentation
dbt docs generate

# Serve documentation site
dbt docs serve
```

### Debugging

```bash
# Run in debug mode
dbt --debug run

# Compile model without running
dbt compile --select model_name

# Show compiled SQL
dbt show --select model_name
```

## Development Workflow

### Adding a New Model

1. **Create the SQL file** in appropriate layer directory:
   ```bash
   touch models/silver/slv_new_model.sql
   ```

2. **Write the model**:
   ```sql
   SELECT
       column1,
       column2
   FROM {{ ref('upstream_model') }}
   WHERE condition = true
   ```

3. **Test locally**:
   ```bash
   dbt run --select slv_new_model
   dbt test --select slv_new_model
   ```

4. **Document the model** (optional):
   Create/update YAML file with model description.

### Adding Tests

1. **Schema tests** in YAML:
   ```yaml
   models:
     - name: my_model
       columns:
         - name: id
           tests:
             - unique
             - not_null
   ```

2. **Custom tests** in `tests/`:
   ```sql
   -- tests/my_custom_test.sql
   SELECT *
   FROM {{ ref('my_model') }}
   WHERE invalid_condition
   ```

### Using Macros

Create reusable SQL in `macros/`:
```sql
-- macros/my_macro.sql
{% macro calculate_percent(numerator, denominator) %}
    ({{ numerator }}::float / NULLIF({{ denominator }}, 0)) * 100
{% endmacro %}
```

Use in models:
```sql
SELECT {{ calculate_percent('cases', 'population') }} as case_rate
FROM my_table
```

## Data Quality

### Source Tests
All source tables have `not_null` tests on critical columns defined in `models/staging/raw_covid.yml`.

### Model Tests
Add tests to ensure:
- Unique keys
- Not null values
- Valid relationships
- Business logic constraints

### Best Practices
- Always test models after creation
- Use incremental models for large time-series data
- Document complex transformations
- Keep models focused and modular
- Use descriptive names

## Dependencies

Defined in `packages.yml`:
```yaml
packages:
  - package: dbt-labs/dbt_utils
    version: 1.0.0
```

Install packages:
```bash
dbt deps
```

## Configuration Files

### `dbt_project.yml`
- Project metadata
- Model paths
- Materialization settings
- Layer-specific schemas

### `profiles.yml` (in ~/.dbt/)
- Database connection details
- Target environments (dev, prod)
- Thread configuration

### `packages.yml`
- External dbt package dependencies

## Troubleshooting

### Common Issues

**Connection errors**:
```bash
dbt debug  # Test database connection
```

**Model compilation errors**:
```bash
dbt compile --select model_name
```

**Circular dependencies**:
```bash
dbt run --exclude model_causing_issue
```

**Stale artifacts**:
```bash
dbt clean  # Remove target/ and dbt_packages/
dbt deps   # Reinstall packages
```

## Resources

- [dbt Documentation](https://docs.getdbt.com/)
- [dbt Discourse Community](https://discourse.getdbt.com/)
- [dbt Slack Community](https://community.getdbt.com/)
- [dbt Best Practices](https://docs.getdbt.com/guides/best-practices)

## Model Lineage

```
Sources (raw_covid schema)
    ↓
Staging (stg_*) - Views
    ↓
Bronze (brz__*) - Tables
    ↓
Silver (slv_*) - Tables
    ↓
Gold (dim_*, fact_*, ml_*) - Tables
```

Each layer builds upon the previous, ensuring data quality and traceability throughout the pipeline.
