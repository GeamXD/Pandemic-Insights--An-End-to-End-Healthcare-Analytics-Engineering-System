# Development Guide

This guide covers the development workflow, best practices, and guidelines for contributing to the Pandemic Insights project.

## Project Structure

```
Pandemic-Insights/
├── dbt_covid/                      # dbt project
│   ├── analyses/                   # Ad-hoc queries
│   ├── dbt_project.yml            # dbt configuration
│   ├── macros/                    # Reusable SQL macros
│   │   └── generate_schema_name.sql
│   ├── models/                    # dbt models (core of the project)
│   │   ├── staging/              # Staging layer (views)
│   │   │   ├── sources.yml       # Source definitions and tests
│   │   │   └── stg_*.sql        # Staging models
│   │   ├── bronze/              # Bronze layer (tables)
│   │   │   └── brz__*.sql       # Bronze models
│   │   ├── silver/              # Silver layer (tables)
│   │   │   └── slv_*.sql        # Silver models
│   │   └── gold/                # Gold layer (tables)
│   │       ├── fact_*.sql       # Fact tables
│   │       ├── dim_*.sql        # Dimension tables
│   │       └── ml_*.sql         # ML feature tables
│   ├── packages.yml              # dbt package dependencies
│   ├── seeds/                    # CSV seed files for static data
│   ├── snapshots/                # Snapshot models (SCD Type 2)
│   └── tests/                    # Custom data tests
│
├── dbt_covid_dag/                # Airflow project
│   ├── dags/                     # Airflow DAGs
│   │   ├── dbt_covid/            # dbt project copy for Airflow
│   │   └── covid_dag.py         # Main DAG definition
│   ├── Dockerfile               # Airflow container image
│   ├── docker-compose.override.yml
│   ├── packages.txt             # OS packages
│   ├── requirements.txt         # Python packages
│   └── tests/                   # DAG tests
│
├── data/                         # Data directory
│   └── raw/                     # Raw CSV files
│
├── docs/                         # Documentation
│   ├── ARCHITECTURE.md          # System architecture
│   ├── DATA_MODEL.md            # Data model documentation
│   ├── DEVELOPMENT.md           # This file
│   └── SETUP.md                 # Setup instructions
│
├── requirements.txt              # Root Python dependencies
├── SCHEMA AND LOAD.sql          # Database schema creation script
└── README.md                    # Project overview
```

## Development Workflow

### 1. Setting Up Development Environment

```bash
# Clone repository
git clone <repo-url>
cd Pandemic-Insights

# Create virtual environment
python -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt

# Configure dbt profile
# Edit ~/.dbt/profiles.yml with your BigQuery connection
```

### 2. Working with dbt

#### Daily Development Commands

```bash
cd dbt_covid

# Check connection
dbt debug

# Install/update packages
dbt deps

# Compile models (check for SQL errors)
dbt compile

# Run specific model
dbt run --select model_name

# Run model and its downstream dependencies
dbt run --select model_name+

# Run model and its upstream dependencies
dbt run --select +model_name

# Run all models in a directory
dbt run --select staging
dbt run --select bronze
dbt run --select silver
dbt run --select gold

# Run with full refresh (drop and recreate)
dbt run --full-refresh

# Test models
dbt test
dbt test --select model_name

# Run and test together
dbt build
dbt build --select model_name

# Generate documentation
dbt docs generate
dbt docs serve  # Opens browser at http://localhost:8080
```

#### Model Development Process

1. **Plan the Model**
   - Identify source data
   - Define grain (what does one row represent?)
   - List required columns
   - Define business logic

2. **Create the Model File**
   ```bash
   # Create SQL file in appropriate directory
   touch models/silver/slv_new_model.sql
   ```

3. **Write the SQL**
   ```sql
   -- slv_new_model.sql
   -- Always include comments explaining the model
   
   WITH source_data AS (
       SELECT *
       FROM {{ ref('brz__source_table') }}
   )
   
   SELECT
       column1,
       column2,
       CAST(column3 AS FLOAT) as column3
   FROM source_data
   WHERE column1 IS NOT NULL
   ```

4. **Configure Materialization** (optional)
   ```sql
   -- Add config at top of file if different from defaults
   {{ config(
       materialized='table',
       schema='silver'
   ) }}
   ```

5. **Test Locally**
   ```bash
   dbt run --select slv_new_model
   dbt test --select slv_new_model
   ```

6. **Add Documentation** (optional but recommended)
   Create or update schema.yml:
   ```yaml
   version: 2
   
   models:
     - name: slv_new_model
       description: "Description of what this model does"
       columns:
         - name: column1
           description: "Description of column1"
           tests:
             - not_null
             - unique
   ```

7. **Commit Changes**
   ```bash
   git add models/silver/slv_new_model.sql
   git commit -m "Add new silver model for X"
   ```

### 3. Working with Airflow

#### Local Development with Astronomer CLI

```bash
cd dbt_covid_dag

# Start Airflow locally
astro dev start

# View logs
astro dev logs

# Restart after changes
astro dev restart

# Stop Airflow
astro dev stop

# Run pytest for DAG validation
astro dev pytest
```

#### Modifying the DAG

1. Edit `dbt_covid_dag/dags/covid_dag.py`
2. Save the file
3. Airflow will automatically detect changes (may take 30 seconds)
4. Refresh Airflow UI to see updates

#### Testing DAG Changes

```bash
# Parse the DAG
python dags/covid_dag.py

# Or use Airflow CLI in container
astro dev bash
airflow dags test dbt_covid_dag 2023-01-01
```

## Best Practices

### dbt Model Development

#### 1. Naming Conventions

- **Staging**: `stg_{source}__{table}` (e.g., `stg_raw_covid__new_cases`)
- **Bronze**: `brz__{table}` (e.g., `brz__new_cases_7day_avg`)
- **Silver**: `slv_{business_entity}` (e.g., `slv_covid_daily`)
- **Gold Facts**: `fact_{entity}` (e.g., `fact_covid_daily`)
- **Gold Dimensions**: `dim_{entity}` (e.g., `dim_country`)
- **ML Models**: `ml_{purpose}` (e.g., `ml_features`)

#### 2. Model Organization

- **One model per file**: Each SQL file should create one model
- **Layer separation**: Keep models in appropriate directories
- **Logical grouping**: Related models in same layer
- **Dependencies**: Use `{{ ref() }}` for all model references

#### 3. SQL Style Guide

```sql
-- Good: Clear, readable SQL (BigQuery syntax)
SELECT
    -- Keys
    country_code,
    date_key,
    
    -- Measures
    SUM(new_cases) as total_cases,
    AVG(stringency_index) as avg_stringency,
    
    -- Calculated fields (using BigQuery's SAFE_DIVIDE)
    SAFE_DIVIDE(SUM(new_deaths), SUM(new_cases)) * 100 as case_fatality_rate

FROM {{ ref('slv_covid_daily') }}
WHERE date_key >= '2020-01-01'
    AND new_cases > 0
GROUP BY 
    country_code,
    date_key
ORDER BY 
    country_code,
    date_key
```

**Key Points**:
- Lowercase SQL keywords (SELECT, FROM, WHERE)
- Clear indentation (4 spaces)
- Group related columns
- Add comments for complex logic
- Use meaningful aliases
- Handle nulls and division by zero

#### 4. CTEs (Common Table Expressions)

Use CTEs for complex queries:

```sql
WITH base_data AS (
    SELECT *
    FROM {{ ref('brz__source_1') }}
),

enriched_data AS (
    SELECT
        b.*,
        e.additional_field
    FROM base_data b
    LEFT JOIN {{ ref('brz__source_2') }} e
        ON b.key = e.key
),

final AS (
    SELECT
        key,
        field1,
        additional_field,
        CASE 
            WHEN condition THEN value1
            ELSE value2
        END as calculated_field
    FROM enriched_data
)

SELECT * FROM final
```

#### 5. Testing Strategy

**Essential Tests**:
- `not_null` on primary keys and critical fields
- `unique` on primary keys
- `relationships` for foreign keys
- Custom tests for business rules

Example in schema.yml:
```yaml
models:
  - name: fact_covid_daily
    description: "Daily COVID metrics"
    columns:
      - name: country_key
        description: "Country identifier"
        tests:
          - not_null
          - relationships:
              to: ref('dim_country')
              field: country_key
      
      - name: date_key
        description: "Date identifier"
        tests:
          - not_null
      
      - name: new_cases_7day_avg
        description: "7-day rolling average of cases"
        tests:
          - not_null
          - dbt_utils.expression_is_true:
              expression: ">= 0"
```

#### 6. Documentation

- Add model descriptions in schema.yml files
- Include column descriptions
- Document business logic in SQL comments
- Keep README files updated
- Generate dbt docs regularly

#### 7. Performance Optimization

- **Use appropriate materialization**:
  - Views: Staging (no storage)
  - Tables: Bronze, Silver, Gold (better query performance)
  - Incremental: Very large time-series (not currently used)

- **Leverage BigQuery features**:
  - Partitioning: Partition large tables by date
  ```sql
  {{ config(
      materialized='table',
      partition_by={
          "field": "date_key",
          "data_type": "date"
      }
  ) }}
  ```
  
  - Clustering: Define clustering columns
  ```sql
  {{ config(
      materialized='table',
      cluster_by=["country_key", "date_key"]
  ) }}
  ```

- **Limit data in development**:
  ```sql
  SELECT *
  FROM {{ ref('large_table') }}
  {% if target.name == 'dev' %}
  WHERE date_key >= DATE_SUB(CURRENT_DATE(), INTERVAL 30 DAY)
  {% endif %}
  ```

### Version Control

#### Git Workflow

```bash
# Create feature branch
git checkout -b feature/new-model

# Make changes and test
dbt run --select new_model
dbt test --select new_model

# Commit changes
git add .
git commit -m "Add new_model for X functionality"

# Push to remote
git push origin feature/new-model

# Create pull request on GitHub
```

#### Commit Messages

Follow conventional commit format:
```
feat: Add new silver model for monthly aggregations
fix: Correct null handling in slv_covid_daily
docs: Update DATA_MODEL.md with new tables
refactor: Simplify bronze layer transformations
test: Add uniqueness test for fact_covid_daily
```

### Code Review

When reviewing PRs, check:
- [ ] SQL syntax is correct
- [ ] Model runs successfully (`dbt run`)
- [ ] Tests pass (`dbt test`)
- [ ] Documentation is updated
- [ ] Follows naming conventions
- [ ] Appropriate materialization
- [ ] Handles nulls and edge cases
- [ ] No hardcoded values
- [ ] Efficient SQL (no unnecessary joins)

## Testing

### Running Tests

```bash
# All tests
dbt test

# Specific model tests
dbt test --select model_name

# Specific test type
dbt test --select test_type:unique
dbt test --select test_type:not_null

# Source freshness tests
dbt source freshness
```

### Custom Tests

Create custom tests in `tests/` directory:

```sql
-- tests/assert_no_negative_cases.sql
SELECT *
FROM {{ ref('fact_covid_daily') }}
WHERE new_cases_7day_avg < 0
```

If this query returns rows, the test fails.

### Airflow DAG Tests

```bash
cd dbt_covid_dag

# Run pytest
astro dev pytest

# Or manually
pytest tests/dags/
```

## Debugging

### dbt Debugging

```bash
# Compile model to see generated SQL
dbt compile --select model_name
# Check target/compiled/dbt_covid/models/...

# Run with debug output
dbt run --select model_name --debug

# Run in fail-fast mode (stop on first error)
dbt run --fail-fast

# Show model dependencies
dbt list --select +model_name+

# Show SQL preview
dbt show --select model_name
```

### Common Issues

**Issue**: Model not found  
**Solution**: Check model name and use `dbt list` to see all models

**Issue**: Circular dependency  
**Solution**: Review `dbt list --select model_name+` to identify cycle

**Issue**: Database error  
**Solution**: Check compiled SQL in `target/compiled/`, run in database directly

**Issue**: Test failing  
**Solution**: Run the compiled test SQL to see which rows fail

## Deployment

### Production Deployment Checklist

- [ ] All models run successfully
- [ ] All tests pass
- [ ] Documentation is updated
- [ ] Code reviewed and approved
- [ ] Merged to main branch
- [ ] Airflow DAG tested
- [ ] Database credentials configured
- [ ] Monitoring/alerting configured

### Environment Management

Use dbt profiles for different environments:

```yaml
# ~/.dbt/profiles.yml
dbt_covid:
  target: dev
  outputs:
    dev:
      type: bigquery
      method: service-account
      project: YOUR_PROJECT_ID
      dataset: covid
      location: US
      keyfile: /path/to/dev-keyfile.json
      threads: 4
      timeout_seconds: 300
      
    prod:
      type: bigquery
      method: service-account
      project: YOUR_PROJECT_ID
      dataset: covid
      location: US
      keyfile: "{{ env_var('GOOGLE_APPLICATION_CREDENTIALS') }}"
      threads: 8
      timeout_seconds: 600
```

Run for specific environment:
```bash
dbt run --target prod
```

## Monitoring and Maintenance

### Regular Tasks

**Daily**:
- Monitor Airflow DAG runs
- Check for failed tasks
- Review data quality test results

**Weekly**:
- Review dbt model performance
- Check disk space
- Review logs for errors

**Monthly**:
- Update dependencies (`dbt deps --upgrade`)
- Review and optimize slow models
- Backup database
- Archive old logs

### Alerts to Set Up

- DAG failure
- dbt model failure
- Data quality test failure
- Source freshness failure
- Disk space low
- Database connection issues

## Resources

### Documentation
- [dbt Documentation](https://docs.getdbt.com/)
- [Apache Airflow Documentation](https://airflow.apache.org/docs/)
- [Astronomer Documentation](https://docs.astronomer.io/)
- [BigQuery Documentation](https://cloud.google.com/bigquery/docs)

### Learning Resources
- [dbt Learn](https://courses.getdbt.com/)
- [Analytics Engineering Guide](https://www.getdbt.com/analytics-engineering/)
- [Astronomer Academy](https://academy.astronomer.io/)

### Community
- [dbt Slack Community](https://www.getdbt.com/community/)
- [Airflow Slack](https://apache-airflow-slack.herokuapp.com/)
- [Project GitHub Issues](https://github.com/GeamXD/Pandemic-Insights--An-End-to-End-Healthcare-Analytics-Engineering-System/issues)

## Getting Help

1. **Check Documentation**: Review this guide and other docs
2. **Search Logs**: Check dbt/Airflow logs for error messages
3. **Test Locally**: Isolate the issue with specific model runs
4. **Ask Community**: Post in dbt/Airflow Slack
5. **Create Issue**: Open GitHub issue with details

## Contributing

We welcome contributions! Please:
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests and documentation
5. Submit a pull request

See the main README.md for detailed contributing guidelines.
