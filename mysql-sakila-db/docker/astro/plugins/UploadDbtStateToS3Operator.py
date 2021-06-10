import glob
from airflow.models import BaseOperator
from airflow.providers.amazon.aws.hooks.s3 import S3Hook
from airflow.utils.decorators import apply_defaults


class UploadDbtStateToS3Operator(BaseOperator):

    template_fields = ('aws_conn_id', 'bucket_name')

    @apply_defaults
    def __init__(self,
                 aws_conn_id='',
                 bucket_name='',
                 files_path='',
                 *args, **kwargs):

        super(UploadDbtStateToS3Operator, self).__init__(*args, **kwargs)
        self.aws_conn_id = aws_conn_id
        self.bucket_name = bucket_name
        self.files_path = files_path

    def execute(self, context):

        s3_hook = S3Hook(aws_conn_id=self.aws_conn_id)

        self.log.info(f'starting to upload files to {self.bucket_name}...')
        s_local_filespath = f"{self.files_path}/*.json"
        self.log.info(f's_local_filespath {s_local_filespath} ...')

        file_count = 0
        for file_count, s_filepath in enumerate(glob.glob(s_local_filespath)):
            s_fname = s_filepath.split('/')[-1]
            s_s3path = f"dbt/target/{context['ts_nodash']}/"
            s3_hook.load_file(
                filename=s_filepath,
                bucket_name=self.bucket_name,
                replace=True,
                key=s_s3path+s_fname)

            s_s3path = f"dbt/target/latest/"
            s3_hook.load_file(
                filename=s_filepath,
                bucket_name=self.bucket_name,
                replace=True,
                key=s_s3path+s_fname)
                
        self.log.info(f'uploaded {file_count} files...')
