"""
Gaming Analytics Data Pipeline DAG

Orchestrates the end-to-end data pipeline:
1. Generate fresh data (simulating daily data refresh)
2. Load data to warehouse bronze layer
3. Run DBT transformations (bronze → silver → gold)
4. Run data quality tests
"""

from airflow import DAG
from airflow.operators.bash import BashOperator
from airflow.operators.python import PythonOperator
from datetime import datetime, timedelta
import sys
sys.path.insert(0, '/opt/airflow/scripts')

default_args = {
    'owner': 'data-engineering',
    'depends_on_past': False,
    'email_on_failure': False,
    'email_on_retry': False,
    'retries': 2,
    'retry_delay': timedelta(minutes=5),
}

with DAG(
    'gaming_analytics_pipeline',
    default_args=default_args,
    description='End-to-end gaming analytics data pipeline',
    schedule_interval='0 2 * * *',  # Run daily at 2 AM
    start_date=datetime(2024, 11, 1),
    catchup=False,
    tags=['gaming', 'analytics', 'dbt'],
) as dag:

    # Task 1: Generate synthetic data
    generate_data = BashOperator(
        task_id='generate_gaming_data',
        bash_command='python /opt/airflow/scripts/generate_gaming_data.py',
    )

    # Task 2: Truncate bronze tables (for demo - in production use incremental loads)
    truncate_bronze = BashOperator(
        task_id='truncate_bronze_tables',
        bash_command="""
        psql postgresql://warehouse:warehouse@warehouse:5432/gaming_dwh \
        -c "TRUNCATE bronze.player_demographics, bronze.player_events, bronze.purchases CASCADE;"
        """,
    )

    # Task 3: Load data to warehouse
    load_data = BashOperator(
        task_id='load_data_to_warehouse',
        bash_command='python /opt/airflow/scripts/load_data_to_warehouse.py',
    )

    # Task 4: Run DBT models
    dbt_run = BashOperator(
        task_id='dbt_run_models',
        bash_command='cd /opt/airflow/gaming_dbt && dbt run',
    )

    # Task 5: Run DBT tests
    dbt_test = BashOperator(
        task_id='dbt_test_quality',
        bash_command='cd /opt/airflow/gaming_dbt && dbt test',
    )

    # Task 6: Generate DBT docs
    dbt_docs = BashOperator(
        task_id='dbt_generate_docs',
        bash_command='cd /opt/airflow/gaming_dbt && dbt docs generate',
    )

    # Define task dependencies
    generate_data >> truncate_bronze >> load_data >> dbt_run >> dbt_test >> dbt_docs
