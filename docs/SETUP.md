# Setup and Installation Guide

This guide will walk you through setting up the Pandemic Insights analytics system on your local machine.

## Prerequisites

### Required Software
- **Python**: 3.8 or higher
- **PostgreSQL**: 12 or higher
- **Docker**: 20.10 or higher (for Airflow)
- **Docker Compose**: 1.29 or higher (for Airflow)
- **Git**: 2.x or higher

### Optional Software
- **Astronomer CLI**: For easier Airflow development (recommended)
- **dbt Cloud**: Alternative to local dbt setup

## Installation Steps

### 1. Clone the Repository

```bash
git clone https://github.com/GeamXD/Pandemic-Insights--An-End-to-End-Healthcare-Analytics-Engineering-System.git
cd Pandemic-Insights--An-End-to-End-Healthcare-Analytics-Engineering-System
```

### 2. Database Setup

#### Create PostgreSQL Database

```bash
# Connect to PostgreSQL
psql -U postgres

# Create database
CREATE DATABASE covid;

# Connect to the covid database
\c covid

# Create raw schema
CREATE SCHEMA IF NOT EXISTS raw_covid;
```

#### Load Raw Data Schema

```bash
# From the project root directory
psql -U postgres -d covid -f "SCHEMA AND LOAD.sql"
```

This script will create 18 raw tables in the `raw_covid` schema:
- vaccine_administered
- tests_conducted_7_day_avg
- stringency_index
- new_deaths_per_month
- new_deaths_7_day_avg
- new_cases_per_month
- new_cases_7day_avg
- median_age_and_life_expectancy
- human_development_index
- hopsital_beds_and_handwashing
- high_risk_age_groups
- gross_domestic_product
- diabetes_prevalence
- death_rate_from_cardiovascular_disease
- population
- smoking

#### Load CSV Data

You need to load the CSV files from the `data/raw/` directory into the PostgreSQL tables. You can use:

**Option 1: psql COPY command**
```sql
-- Example for one table
\COPY raw_covid.new_cases_7day_avg FROM '/path/to/data/raw/new-cases-7day-avg.csv' DELIMITER ',' CSV HEADER;
```

**Option 2: Python script**
```python
import pandas as pd
from sqlalchemy import create_engine

engine = create_engine('postgresql://postgres:password@localhost:5432/covid')

# Load all CSV files
csv_files = {
    'new-cases-7day-avg.csv': 'new_cases_7day_avg',
    'new-deaths-7-day-avg.csv': 'new_deaths_7_day_avg',
    # ... add all other files
}

for csv_file, table_name in csv_files.items():
    df = pd.read_csv(f'data/raw/{csv_file}')
    df.to_sql(table_name, engine, schema='raw_covid', if_exists='replace', index=False)
```

### 3. dbt Setup

#### Install dbt

```bash
# Create virtual environment (recommended)
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate

# Install dbt and dependencies
pip install -r requirements.txt
```

#### Configure dbt Profile

Create or edit `~/.dbt/profiles.yml`:

```yaml
covid:
  target: dev
  outputs:
    dev:
      type: postgres
      host: localhost
      user: postgres
      password: your_password
      port: 5432
      dbname: covid
      schema: staging
      threads: 4
      keepalives_idle: 0
    
    prod:
      type: postgres
      host: your_prod_host
      user: postgres
      password: your_prod_password
      port: 5432
      dbname: covid
      schema: staging
      threads: 8
      keepalives_idle: 0
```

#### Test dbt Connection

```bash
cd covid
dbt debug
```

You should see `All checks passed!` if everything is configured correctly.

#### Install dbt Packages

```bash
cd covid
dbt deps
```

#### Run dbt Models

```bash
# Run all models
dbt run

# Run with tests
dbt build

# Run specific models
dbt run --select staging
dbt run --select bronze
dbt run --select silver
dbt run --select gold
```

### 4. Airflow Setup (Optional but Recommended)

#### Option A: Using Astronomer CLI (Recommended)

**Install Astronomer CLI:**
```bash
# macOS/Linux
curl -sSL install.astronomer.io | sudo bash -s

# Windows (use WSL or Git Bash)
# Download from https://github.com/astronomer/astro-cli/releases
```

**Initialize and Start Airflow:**
```bash
cd covid_dbt_dag

# Initialize Astronomer project (if needed)
astro dev init

# Start Airflow
astro dev start
```

This will start:
- Airflow Webserver: http://localhost:8080
- Postgres Database: localhost:5432
- Default credentials: admin/admin

**Access Airflow UI:**
1. Navigate to http://localhost:8080
2. Login with admin/admin
3. Enable the `dbt_covid_dag` DAG

#### Option B: Using Docker Compose

```bash
cd covid_dbt_dag

# Start Airflow
docker-compose up -d

# Check status
docker-compose ps

# View logs
docker-compose logs -f
```

#### Configure Airflow Connection

In Airflow UI (Admin → Connections), create a new connection:
- **Conn Id**: `postgres_covid`
- **Conn Type**: Postgres
- **Host**: host.docker.internal (for Docker) or localhost
- **Schema**: covid
- **Login**: postgres
- **Password**: your_password
- **Port**: 5432

#### Copy dbt Project to Airflow

The DAG expects the dbt project at `/usr/local/airflow/dags/covid`. This is handled by the volume mount in `docker-compose.override.yml`.

### 5. Verify Installation

#### Check dbt Models

```bash
cd covid

# List all models
dbt ls

# Run and test all models
dbt build

# Generate documentation
dbt docs generate
dbt docs serve
```

#### Check Airflow DAG

1. Go to http://localhost:8080
2. Find `dbt_covid_dag`
3. Trigger the DAG manually
4. Monitor the execution in Graph/Tree view

#### Verify Database Tables

```sql
-- Connect to PostgreSQL
psql -U postgres -d covid

-- Check schemas
\dn

-- Check tables in each schema
\dt raw_covid.*
\dt bronze.*
\dt silver.*
\dt gold.*

-- Query a gold table
SELECT * FROM gold.fact_covid_daily LIMIT 10;
```

## Configuration Files

### Project Configuration Files

| File | Purpose | Location |
|------|---------|----------|
| `dbt_project.yml` | dbt project configuration | `covid/` |
| `profiles.yml` | dbt connection profiles | `~/.dbt/` |
| `requirements.txt` | Python dependencies | Root & `covid_dbt_dag/` |
| `packages.yml` | dbt package dependencies | `covid/` |
| `covid_dag.py` | Airflow DAG definition | `covid_dbt_dag/dags/` |
| `Dockerfile` | Airflow container image | `covid_dbt_dag/` |

### Environment Variables

For Airflow, you can set these in `.env` file in `covid_dbt_dag/`:

```env
AIRFLOW_UID=50000
_AIRFLOW_WWW_USER_USERNAME=admin
_AIRFLOW_WWW_USER_PASSWORD=admin
POSTGRES_USER=postgres
POSTGRES_PASSWORD=postgres
POSTGRES_DB=covid
```

## Troubleshooting

### Common Issues

#### 1. dbt Connection Error
**Error**: `Could not connect to database`

**Solution**:
- Check PostgreSQL is running: `pg_isready`
- Verify credentials in `~/.dbt/profiles.yml`
- Test connection: `psql -U postgres -d covid`

#### 2. Airflow DAG Not Visible
**Error**: DAG not showing in Airflow UI

**Solution**:
- Check DAG file for syntax errors
- Verify volume mounts in docker-compose
- Check Airflow logs: `docker-compose logs webserver`

#### 3. dbt Models Failing
**Error**: Models failing to build

**Solution**:
- Check raw data is loaded: `SELECT COUNT(*) FROM raw_covid.new_cases_7day_avg;`
- Run with verbose logging: `dbt run --debug`
- Check model dependencies: `dbt list --select model_name+`

#### 4. Port Already in Use
**Error**: Port 8080 already allocated

**Solution**:
- Change port in `docker-compose.override.yml`
- Or stop existing service using port 8080

#### 5. Permission Denied Errors
**Error**: Permission denied when running dbt

**Solution**:
- Check PostgreSQL user permissions
- Grant necessary privileges:
```sql
GRANT CREATE ON SCHEMA bronze TO postgres;
GRANT CREATE ON SCHEMA silver TO postgres;
GRANT CREATE ON SCHEMA gold TO postgres;
```

### Getting Help

- **dbt Documentation**: https://docs.getdbt.com/
- **Airflow Documentation**: https://airflow.apache.org/docs/
- **Astronomer Documentation**: https://docs.astronomer.io/
- **Project Issues**: https://github.com/GeamXD/Pandemic-Insights--An-End-to-End-Healthcare-Analytics-Engineering-System/issues

## Next Steps

After successful setup:
1. Read the [Architecture Documentation](ARCHITECTURE.md)
2. Review the [Data Model Documentation](DATA_MODEL.md)
3. Check the [Development Guide](DEVELOPMENT.md)
4. Start developing your own models and analytics!

## Maintenance

### Regular Tasks

- **Update dbt packages**: `dbt deps --upgrade`
- **Update Python dependencies**: `pip install --upgrade -r requirements.txt`
- **Update Airflow**: `astro dev upgrade` or update base image in Dockerfile
- **Vacuum database**: Regular PostgreSQL maintenance
- **Monitor disk space**: For Airflow logs and database

### Backup

Regularly backup:
- PostgreSQL database
- dbt models and configuration
- Airflow DAG files
- Documentation
