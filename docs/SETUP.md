# Setup and Installation Guide

This guide will walk you through setting up the Pandemic Insights analytics system on your local machine.

## Prerequisites

### Required Software
- **Python**: 3.8 or higher
- **Google Cloud SDK**: For BigQuery CLI access
- **Google Cloud Platform Account**: With BigQuery enabled
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

### 2. BigQuery Setup

#### Create BigQuery Project and Dataset

**Option 1: Using GCP Console**
1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select an existing one
3. Enable BigQuery API
4. Navigate to BigQuery in the console
5. Create a dataset named `covid` with location `US`

**Option 2: Using gcloud CLI**
```bash
# Set your project
gcloud config set project YOUR_PROJECT_ID

# Create the dataset
bq mk --dataset --location=US YOUR_PROJECT_ID:covid

# Verify the dataset was created
bq ls
```

#### Set Up Authentication

**Create a Service Account:**
```bash
# Create service account
gcloud iam service-accounts create dbt-bigquery-sa \
    --display-name="dbt BigQuery Service Account"

# Grant BigQuery permissions
gcloud projects add-iam-policy-binding YOUR_PROJECT_ID \
    --member="serviceAccount:dbt-bigquery-sa@YOUR_PROJECT_ID.iam.gserviceaccount.com" \
    --role="roles/bigquery.admin"

# Create and download key
gcloud iam service-accounts keys create ~/dbt-bigquery-key.json \
    --iam-account=dbt-bigquery-sa@YOUR_PROJECT_ID.iam.gserviceaccount.com
```

#### Load Raw Data

Use the provided shell script to load CSV files into BigQuery:

```bash
# From the project root directory
./raw_files_to_bigquery.sh
```

Or manually load using BigQuery CLI:
```bash
# Example for loading one table
bq load \
  --source_format=CSV \
  --skip_leading_rows=1 \
  --autodetect \
  YOUR_PROJECT_ID:covid.new_cases_7day_avg \
  data/raw/new-cases-7day-avg.csv
```

#### Verify Data Load

```bash
# List tables in the dataset
bq ls YOUR_PROJECT_ID:covid

# Query a table to verify data
bq query --use_legacy_sql=false \
  'SELECT COUNT(*) as row_count FROM `YOUR_PROJECT_ID.covid.new_cases_7day_avg`'
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
dbt_covid:
  target: dev
  outputs:
    dev:
      type: bigquery
      method: service-account
      project: YOUR_PROJECT_ID
      dataset: covid
      location: US
      keyfile: /path/to/your/dbt-bigquery-key.json
      threads: 4
      timeout_seconds: 300
    
    prod:
      type: bigquery
      method: service-account
      project: YOUR_PROJECT_ID
      dataset: covid
      location: US
      keyfile: /path/to/your/dbt-bigquery-key.json
      threads: 8
      timeout_seconds: 300
```

**Alternative: Using OAuth (for development)**
```yaml
dbt_covid:
  target: dev
  outputs:
    dev:
      type: bigquery
      method: oauth
      project: YOUR_PROJECT_ID
      dataset: covid
      location: US
      threads: 4
      timeout_seconds: 300
```

#### Test dbt Connection

```bash
cd dbt_covid
dbt debug
```

You should see `All checks passed!` if everything is configured correctly.

#### Install dbt Packages

```bash
cd dbt_covid
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
cd dbt_covid_dag

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
cd dbt_covid_dag

# Start Airflow
docker-compose up -d

# Check status
docker-compose ps

# View logs
docker-compose logs -f
```

#### Configure Airflow Connection

In Airflow UI (Admin → Connections), create a new connection:
- **Conn Id**: `google_cloud_default`
- **Conn Type**: Google Cloud
- **Project Id**: YOUR_PROJECT_ID
- **Keyfile Path**: (leave empty if using Keyfile JSON)
- **Keyfile JSON**: Paste contents of your service account JSON key file
- **Scopes**: https://www.googleapis.com/auth/bigquery

#### Copy dbt Project to Airflow

The DAG expects the dbt project at `/usr/local/airflow/dags/dbt_covid`. This is handled by the volume mount in `docker-compose.override.yml`.

### 5. Verify Installation

#### Check dbt Models

```bash
cd dbt_covid

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

```bash
# List datasets
bq ls

# List tables in covid dataset
bq ls YOUR_PROJECT_ID:covid

# Query a gold table
bq query --use_legacy_sql=false \
  'SELECT * FROM `YOUR_PROJECT_ID.covid.fact_covid_daily` LIMIT 10'
```

## Configuration Files

### Project Configuration Files

| File | Purpose | Location |
|------|---------|----------|
| `dbt_project.yml` | dbt project configuration | `dbt_covid/` |
| `profiles.yml` | dbt connection profiles | `~/.dbt/` |
| `requirements.txt` | Python dependencies | Root & `dbt_covid_dag/` |
| `packages.yml` | dbt package dependencies | `dbt_covid/` |
| `covid_dag.py` | Airflow DAG definition | `dbt_covid_dag/dags/` |
| `Dockerfile` | Airflow container image | `dbt_covid_dag/` |

### Environment Variables

For Airflow, you can set these in `.env` file in `dbt_covid_dag/`:

```env
AIRFLOW_UID=50000
_AIRFLOW_WWW_USER_USERNAME=admin
_AIRFLOW_WWW_USER_PASSWORD=admin
GOOGLE_APPLICATION_CREDENTIALS=/path/to/dbt-bigquery-key.json
```

## Troubleshooting

### Common Issues

#### 1. dbt Connection Error
**Error**: `Could not connect to BigQuery`

**Solution**:
- Check service account permissions
- Verify keyfile path in `~/.dbt/profiles.yml`
- Test connection: `dbt debug`
- Ensure BigQuery API is enabled

#### 2. Airflow DAG Not Visible
**Error**: DAG not showing in Airflow UI

**Solution**:
- Check DAG file for syntax errors
- Verify volume mounts in docker-compose
- Check Airflow logs: `docker-compose logs webserver`

#### 3. dbt Models Failing
**Error**: Models failing to build

**Solution**:
- Check raw data is loaded: `bq query --use_legacy_sql=false 'SELECT COUNT(*) FROM \`YOUR_PROJECT_ID.covid.new_cases_7day_avg\`'`
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
- Check BigQuery IAM permissions for service account
- Ensure service account has `BigQuery Data Editor` and `BigQuery Job User` roles:
```bash
gcloud projects add-iam-policy-binding YOUR_PROJECT_ID \
    --member="serviceAccount:dbt-bigquery-sa@YOUR_PROJECT_ID.iam.gserviceaccount.com" \
    --role="roles/bigquery.dataEditor"

gcloud projects add-iam-policy-binding YOUR_PROJECT_ID \
    --member="serviceAccount:dbt-bigquery-sa@YOUR_PROJECT_ID.iam.gserviceaccount.com" \
    --role="roles/bigquery.jobUser"
```

### Getting Help

- **dbt Documentation**: https://docs.getdbt.com/
- **BigQuery Documentation**: https://cloud.google.com/bigquery/docs
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
- BigQuery datasets (using BigQuery export or snapshots)
- dbt models and configuration
- Airflow DAG files
- Documentation
