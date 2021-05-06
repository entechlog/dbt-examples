import glob
from airflow.models import BaseOperator
from airflow.providers.amazon.aws.hooks.s3 import S3Hook
from airflow.utils.decorators import apply_defaults

class S3UploadOperator(BaseOperator):

    ui_color = '#80BD9E'

    template_fields = ('aws_conn_id', 'dest_bucket_name')

    @apply_defaults
    def __init__(self,
                 aws_conn_id='',
                 dest_bucket_name='',
                 files_path='',
                 singlefile_path='',
                 *args, **kwargs):

        super(S3UploadOperator, self).__init__(*args, **kwargs)
        self.aws_conn_id = aws_conn_id
        self.dest_bucket_name = dest_bucket_name
        self.files_path = files_path
        self.singlefile_path = singlefile_path

    def execute(self, context):

        s3_hook = S3Hook(aws_conn_id=self.aws_conn_id)

        if self.singlefile_path:
            s_fname = self.singlefile_path.split('/')[-1]
            s3_hook.load_file(
                filename=self.singlefile_path,
                bucket_name=self.dest_bucket_name,
                replace=True,
                key=s_fname)
            self.log.info(f'uploaded file in {self.singlefile_path}...')
            return
        self.log.info(f'start to upload files to {self.dest_bucket_name}...')
        s_local_filespath = f"{self.files_path}/{context['ds_nodash']}*.json"
        s_local_filespath = f"{self.files_path}/*.json"
        self.log.info(f's_local_filespath {s_local_filespath} ...')
        ii = 0
        for ii, s_filepath in enumerate(glob.glob(s_local_filespath)):
            s_fname = s_filepath.split('/')[-1]
            s3_hook.load_file(
                filename=s_filepath,
                bucket_name=self.dest_bucket_name,
                replace=True,
                key=s_fname)

        self.log.info(f'uploaded {ii} files...')
