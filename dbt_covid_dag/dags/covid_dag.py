import os
from datetime import datetime
from airflow.hooks.base import BaseHook
from cosmos import DbtDag, ProjectConfig, ProfileConfig, ExecutionConfig
from cosmos.profiles import GoogleCloudServiceAccountDictProfileMapping

# Monkey-patch to fix OpenLineage bug
from cosmos.operators import local as cosmos_local

original_calculate_openlineage = cosmos_local.DbtLocalBaseOperator.calculate_openlineage_events_completes


def patched_calculate_openlineage(self, *args, **kwargs):
    """Wrapper to catch and ignore OpenLineage errors"""
    try:
        return original_calculate_openlineage(self, *args, **kwargs)
    except (KeyError, TypeError, AttributeError) as e:
        # Log the error but don't fail the task
        self.log.warning(f"OpenLineage error (ignored): {e}")
        return []


cosmos_local.DbtLocalBaseOperator.calculate_openlineage_events_completes = patched_calculate_openlineage


def get_keyfile_dict():
    """
    Extract the service account keyfile from Airflow connection.
    Returns the keyfile as a dictionary.
    """
    conn = BaseHook.get_connection("google_cloud_default")
    extra_dejson = conn.extra_dejson

    # Check if the extra field contains the service account keys directly
    if "type" in extra_dejson and "project_id" in extra_dejson and "private_key" in extra_dejson:
        # The service account JSON is stored directly in extra
        return extra_dejson

    # Otherwise, try nested locations
    if "keyfile_dict" in extra_dejson:
        return extra_dejson["keyfile_dict"]

    if "extra__google_cloud_platform__keyfile_dict" in extra_dejson:
        return extra_dejson["extra__google_cloud_platform__keyfile_dict"]

    raise ValueError(
        f"Could not find valid service account credentials in connection 'google_cloud_default'. "
        f"Available keys: {list(extra_dejson.keys())}"
    )


profile_config = ProfileConfig(
    profile_name="dbt_covid",
    target_name="dev",
    profile_mapping=GoogleCloudServiceAccountDictProfileMapping(
        conn_id="google_cloud_default",
        profile_args={
            "project": "healthcare-analytics-471307",
            "dataset": "covid",
            "location": "US",
            "keyfile_json": get_keyfile_dict(),
        },
        disable_event_tracking=True
    )
)

dbt_bigquery_dag = DbtDag(
    project_config=ProjectConfig(
        dbt_project_path="/usr/local/airflow/dags/dbt_covid"
    ),
    operator_args={
        "install_deps": True,
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