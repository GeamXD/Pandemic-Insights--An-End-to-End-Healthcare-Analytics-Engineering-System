# COVID-19 Data Pipeline - Airflow Project

## Overview

This Astronomer Airflow project orchestrates the COVID-19 analytics data pipeline using Cosmos to run dbt transformations. The project uses Docker containers to provide a consistent local development environment.

## Project Structure

```
covid_dbt_dag/
├── dags/
│   ├── covid_dag.py              # Main COVID-19 pipeline DAG
│   ├── covid/                    # dbt project (mounted/symlinked)
│   └── .airflowignore           # Files to ignore
├── tests/
│   └── dags/
│       └── test_dag_example.py  # DAG integrity tests
├── Dockerfile                    # Custom Airflow image with dbt
├── docker-compose.override.yml   # Local PostgreSQL configuration
├── requirements.txt              # Python dependencies
├── packages.txt                  # OS-level packages
└── README.md                     # This file
```

## Architecture

### Components

1. **Scheduler**: Monitors and triggers DAG runs
2. **Webserver**: Provides the Airflow UI (port 8080)
3. **Postgres Metadata DB**: Stores Airflow metadata
4. **Triggerer**: Handles deferred tasks
5. **DAG Processor**: Parses DAG files

### Data Pipeline Flow

```
┌─────────────────────────────────────┐
│     Airflow Scheduler               │
│     (Daily at midnight)             │
└───────────────┬─────────────────────┘
                │
                ▼
┌─────────────────────────────────────┐
│  dbt_covid_dag                      │
│  (Cosmos DbtDag)                    │
└───────────────┬─────────────────────┘
                │
                ▼
        ┌───────────────┐
        │  dbt run      │
        │  (via Cosmos) │
        └───────┬───────┘
                │
    ┌───────────┴───────────┐
    │                       │
    ▼                       ▼
┌─────────┐          ┌─────────┐
│ Staging │          │ Bronze  │
└────┬────┘          └────┬────┘
     │                    │
     └─────────┬──────────┘
               ▼
          ┌─────────┐
          │ Silver  │
          └────┬────┘
               │
               ▼
          ┌─────────┐
          │  Gold   │
          └─────────┘
```

## COVID-19 DAG Details

### Configuration

**File**: `dags/covid_dag.py`

**DAG Parameters**:
- **dag_id**: `dbt_covid_dag`
- **schedule**: `@daily` (runs at midnight UTC)
- **start_date**: September 10, 2023
- **catchup**: `False` (don't backfill historical runs)

**Profile Configuration**:
```python
profile_config = ProfileConfig(
    profile_name="covid",
    target_name="dev",
    profile_mapping=PostgresUserPasswordProfileMapping(
        conn_id="postgres_covid",  # Airflow connection ID
        profile_args={
            "dbname": "covid",
            "schema": "staging"
        },
        disable_event_tracking=True
    )
)
```

**Project Configuration**:
```python
project_config=ProjectConfig(
    dbt_project_path="/usr/local/airflow/dags/covid"
)
```

**Execution Configuration**:
```python
execution_config=ExecutionConfig(
    dbt_executable_path=f"{os.environ.get('AIRFLOW_HOME')}/dbt_venv/bin/dbt"
)
```

### Key Features

1. **Cosmos Integration**: Uses Astronomer Cosmos to convert dbt models into Airflow tasks
2. **Automatic Dependencies**: Task dependencies derived from dbt model relationships
3. **Isolated dbt Environment**: dbt runs in a separate virtual environment
4. **Incremental Execution**: Only runs changed or downstream-impacted models
5. **Dependency Installation**: Automatically installs dbt packages on first run

## Setup Instructions

### Prerequisites

- Docker Desktop installed and running
- Astronomer CLI installed:
  ```bash
  curl -sSL install.astronomer.io | sudo bash -s
  ```
- Minimum 8GB RAM available to Docker

### Local Development Setup

#### 1. Navigate to the Project Directory
```bash
cd covid_dbt_dag
```

#### 2. Start Airflow
```bash
astro dev start
```

This command will:
- Build the custom Docker image (with dbt)
- Start 5 containers (Postgres, Scheduler, Webserver, Triggerer, DAG Processor)
- Mount your DAGs directory
- Expose Airflow UI on port 8080

#### 3. Access Airflow UI
Open browser to: `http://localhost:8080`

**Default Credentials**:
- Username: `admin`
- Password: `admin`

#### 4. Configure PostgreSQL Connection

In Airflow UI:
1. Navigate to **Admin → Connections**
2. Click **+** to add new connection
3. Fill in details:
   - **Connection Id**: `postgres_covid`
   - **Connection Type**: `Postgres`
   - **Host**: `host.docker.internal` (Mac/Windows) or `172.17.0.1` (Linux)
   - **Schema**: `covid`
   - **Login**: `postgres`
   - **Password**: `postgres`
   - **Port**: `5432`

#### 5. Enable and Run the DAG
1. In Airflow UI, find `dbt_covid_dag`
2. Toggle the DAG to **ON**
3. Click the play button (▶) to trigger manually
4. Monitor progress in the Graph or Grid view

### Docker Configuration

#### Custom Dockerfile
The `Dockerfile` extends the Astronomer Runtime image and installs dbt:

```dockerfile
FROM astrocrpublic.azurecr.io/runtime:3.1-9

RUN python -m venv dbt_venv && source dbt_venv/bin/activate && \
    pip install --no-cache-dir dbt-core dbt-postgres && deactivate
```

#### docker-compose.override.yml
Overrides PostgreSQL port for local development:

```yaml
services:
  postgres:
    ports:
      - "5433:5432"  # Avoids conflict with local PostgreSQL on 5432
```

## Development Workflow

### Making DAG Changes

1. **Edit DAG file**:
   ```bash
   vim dags/covid_dag.py
   ```

2. **Verify syntax**:
   ```bash
   python dags/covid_dag.py
   ```

3. **Restart Airflow** (if needed):
   ```bash
   astro dev restart
   ```

4. **Test in UI**:
   - DAG will auto-reload in ~30 seconds
   - Trigger manually to test

### Adding New DAGs

1. Create new Python file in `dags/` directory
2. Define DAG using standard Airflow operators or Cosmos
3. DAG appears automatically in UI (wait for DAG processor)

### Updating dbt Models

The dbt project is mounted into the Airflow container. Changes to dbt models are reflected immediately:

1. Update models in `../covid/models/`
2. DAG will use updated models on next run
3. Test changes: trigger DAG manually

### Viewing Logs

**Stream logs** (all containers):
```bash
astro dev logs
```

**Stream specific component**:
```bash
astro dev logs --follow scheduler
astro dev logs --follow webserver
```

**Access container**:
```bash
astro dev bash --scheduler
astro dev bash --webserver
```

## Airflow Commands

### Container Management
```bash
astro dev start         # Start all containers
astro dev stop          # Stop containers (preserves data)
astro dev restart       # Restart containers
astro dev kill          # Stop and remove containers
astro dev ps            # Show running containers
```

### Development
```bash
astro dev bash          # Access webserver container
astro dev pytest        # Run DAG integrity tests
astro dev run           # Execute Airflow CLI commands
```

### Examples
```bash
# List all DAGs
astro dev run dags list

# Test specific DAG
astro dev run dags test dbt_covid_dag

# List tasks in a DAG
astro dev run tasks list dbt_covid_dag
```

## Monitoring and Debugging

### DAG Views in Airflow UI

1. **Grid View**: Historical run status
2. **Graph View**: Task dependencies and status
3. **Calendar View**: Success/failure patterns over time
4. **Code View**: DAG source code
5. **Gantt View**: Task duration and parallelism

### Task Logs

Access task logs in UI:
1. Click on a task in Graph view
2. Click **Log** button
3. View stdout/stderr from task execution

### Common Issues

#### DAG Not Appearing
**Symptoms**: DAG doesn't show in UI

**Solutions**:
```bash
# Check for syntax errors
python dags/covid_dag.py

# Check DAG processor logs
astro dev logs --follow dag-processor

# Restart Airflow
astro dev restart
```

#### Connection Error
**Symptoms**: Tasks fail with "Connection refused"

**Solutions**:
- Verify `postgres_covid` connection is configured
- Test connection in Airflow UI
- Check host is `host.docker.internal` (not `localhost`)
- Ensure PostgreSQL is running on host machine

#### dbt Command Not Found
**Symptoms**: "dbt: command not found"

**Solutions**:
- Verify `dbt_executable_path` in `covid_dag.py`
- Rebuild image: `astro dev restart --clean`
- Check dbt installation: `astro dev bash` then `source dbt_venv/bin/activate && dbt --version`

#### Memory Issues
**Symptoms**: Containers crash or hang

**Solutions**:
- Increase Docker memory (Docker Desktop → Settings → Resources)
- Reduce dbt threads in profile
- Stop other Docker containers

## Testing

### DAG Integrity Tests

Run automated tests:
```bash
astro dev pytest
```

Tests verify:
- DAG syntax is valid
- No import errors
- DAG structure is correct

### Manual Testing

1. **Test DAG parsing**:
   ```bash
   astro dev run dags list
   ```

2. **Test specific DAG**:
   ```bash
   astro dev run dags test dbt_covid_dag 2024-01-01
   ```

3. **Test single task**:
   ```bash
   astro dev run tasks test dbt_covid_dag task_name 2024-01-01
   ```

## Deployment to Production

### Using Astronomer Cloud

1. **Create Deployment**:
   - Log into Astronomer Cloud
   - Create new deployment
   - Note deployment URL

2. **Deploy**:
   ```bash
   astro deploy
   ```

3. **Configure Production Connections**:
   - Set production database credentials
   - Update `postgres_covid` connection

4. **Monitor**:
   - Use Astronomer Cloud UI
   - Set up alerts for failures

### Using Other Platforms

For deployment to other Airflow platforms (MWAA, Cloud Composer, etc.):

1. Export requirements: Already in `requirements.txt`
2. Package DAGs: Copy `dags/` directory
3. Configure connections in target environment
4. Test thoroughly before production

## Best Practices

### DAG Development
- Keep DAGs simple and focused
- Use descriptive task IDs
- Set appropriate timeouts
- Handle failures gracefully
- Document complex logic

### Performance
- Use appropriate pool sizes
- Set parallelism limits
- Optimize dbt models for incremental runs
- Monitor task duration

### Security
- Never hardcode credentials
- Use Airflow connections and variables
- Rotate secrets regularly
- Limit access to sensitive DAGs

### Monitoring
- Set up email alerts for failures
- Monitor DAG run duration
- Track data quality metrics
- Review logs regularly

## Environment Variables

Key environment variables (set in UI or `airflow_settings.yaml`):

```yaml
AIRFLOW_HOME: /usr/local/airflow
AIRFLOW__CORE__LOAD_EXAMPLES: False
AIRFLOW__WEBSERVER__EXPOSE_CONFIG: True
```

## Cosmos Specifics

### What is Cosmos?

Astronomer Cosmos converts dbt projects into Airflow DAGs, creating:
- One Airflow task per dbt model
- Dependencies based on `ref()` and `source()`
- Automatic model selection and testing

### Benefits
- Native Airflow integration
- Fine-grained task visibility
- Leverage Airflow features (retries, sensors, etc.)
- No need for `BashOperator` workarounds

### Configuration Options

Additional Cosmos parameters available:

```python
DbtDag(
    # ... existing config ...
    select=["tag:daily"],        # Run only specific models
    exclude=["tag:manual"],       # Exclude models
    full_refresh=False,           # Don't truncate incremental models
    operator_args={
        "install_deps": True,     # Install dbt packages
        "vars": {"key": "value"}  # Pass variables to dbt
    }
)
```

## Resources

- [Astronomer Docs](https://docs.astronomer.io/)
- [Airflow Docs](https://airflow.apache.org/docs/)
- [Cosmos Docs](https://astronomer.github.io/astronomer-cosmos/)
- [Astronomer CLI](https://docs.astronomer.io/astro/cli/overview)
- [Astronomer Forum](https://forum.astronomer.io/)

## Support

For issues:
1. Check logs: `astro dev logs`
2. Review Airflow UI for task failures
3. Verify connections and configuration
4. Consult Astronomer documentation
5. Reach out to Astronomer support

---

**Last Updated**: January 2026
