from datetime import timedelta

from airflow import DAG
from airflow.operators.bash_operator import BashOperator
from airflow.utils.dates import datetime
from airflow.utils.dates import timedelta

from S3UploadOperator import S3UploadOperator
from UploadDbtStateToS3Operator import UploadDbtStateToS3Operator
from airflow.models import Variable

# These args will get passed on to each operator
# You can override them on a per-task basis during operator initialization
default_args = {
    'owner': 'astronomer',
    'depends_on_past': False,
    'start_date': datetime(2020, 12, 23),
    'email_on_failure': False,
    'email_on_retry': False,
    'retries': 1,
    'retry_delay': timedelta(minutes=5)
}
dag = DAG(
    'dbt_basic_dag',
    max_active_runs=1,
    default_args=default_args,
    description='An Airflow DAG to invoke DBT',
    schedule_interval=timedelta(days=1),
)

dbt_debug = BashOperator(
    task_id='dbt_debug',
    bash_command='ls -ltra && cd /usr/local/airflow/dbt/ && dbt debug',
    dag=dag
)

dbt_compile = BashOperator(
    task_id='dbt_compile',
    bash_command='cd /usr/local/airflow/dbt/ && dbt compile',
    dag=dag
)

dbt_state_upload = S3UploadOperator(
    task_id='dbt_state_upload',
    aws_conn_id='aws_credentials',
    dest_bucket_name=Variable.get('S3_BUCKET_NAME'),
    files_path=Variable.get('LOCAL_FILES_PATH') + 'target',
    dag=dag
    )

dbt_state_upload_dir = UploadDbtStateToS3Operator(
    task_id='dbt_state_upload_dir',
    aws_conn_id='aws_credentials',
    bucket_name=Variable.get('S3_BUCKET_NAME'),
    files_path=Variable.get('LOCAL_FILES_PATH') + 'target',
    dag=dag
    )
    
dbt_debug >> dbt_compile >> dbt_state_upload >> dbt_state_upload_dir
