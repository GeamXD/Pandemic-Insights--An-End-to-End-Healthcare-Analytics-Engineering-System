import os
from datetime import datetime
from cosmos import DbtDag, ProjectConfig, ProfileConfig, ExecutionConfig
from cosmos.profiles import PostgresUserPasswordProfileMapping

profile_config = ProfileConfig(
    profile_name="covid",
    target_name="dev",
    profile_mapping=PostgresUserPasswordProfileMapping(
        conn_id="postgres_covid",
        profile_args={
            "dbname": "covid",    # FIXED: Changed 'database' to 'dbname' for Postgres
            "schema": "staging"
        },
        disable_event_tracking=True
    )
)

dbt_postgres_dag = DbtDag(
    project_config=ProjectConfig(
        # Ensure this path matches the volume mount in your docker-compose
        dbt_project_path="/usr/local/airflow/dags/covid"
    ),
    operator_args={
        "install_deps": True
    },
    profile_config=profile_config,
    execution_config=ExecutionConfig(
        dbt_executable_path=f"{os.environ.get('AIRFLOW_HOME', '/usr/local/airflow')}/dbt_venv/bin/dbt"
    ),
    schedule="@daily",
    start_date=datetime(2023, 9, 10),
    catchup=False,
    dag_id="dbt_covid_dag",
)