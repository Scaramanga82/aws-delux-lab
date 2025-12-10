import sys
import os
import logging
import json
import boto3
from datetime import datetime, timezone
from dotenv import load_dotenv
import pprint
import string
import random

today = (datetime.today()).date()

def id_generator(size=6, chars=string.ascii_uppercase + string.digits):
    return ''.join(random.choice(chars) for _ in range(size))

def handler(event, context):
    env = os.getenv('ENV')
    product_name = os.getenv('PRODUCT_NAME')
    rds_clusteros_arn = os.getenv('RDS_CLUSTER_ARN')
    kms_key_arn = os.getenv('KMS_KEY_ARN')
    export_iam_role_arn = os.getenv('EXPORT_IAM_ROLE_ARN')
    s3_bucket_name = os.getenv('S3_BUCKET_NAME')

    client = boto3.client('rds')

    # Link: https://boto3.amazonaws.com/v1/documentation/api/latest/reference/services/rds.html#RDS.Client.describe_db_cluster_snapshots
    response_db_snapshot = client.describe_db_cluster_snapshots(
        SnapshotType='automated',
        MaxRecords=20,
        Filters=[
            {
                'Name': 'db-cluster-id',
                'Values': [
                    rds_clusteros_arn,
                ]
            },
        ],
    )

    for i in response_db_snapshot['DBClusterSnapshots']:
        if i['SnapshotCreateTime'].date() == today:
            print(i['DBClusterSnapshotIdentifier'])
            print(i['DBClusterSnapshotArn'])
            db_cluster_snapshots_arn = i['DBClusterSnapshotArn']
            print(today)

    s3 = boto3.resource('s3')
    bucket = s3.Bucket(s3_bucket_name)
    bucket.objects.filter(Prefix=f"dbexport").delete()

    # Link: https://boto3.amazonaws.com/v1/documentation/api/latest/reference/services/rds.html#RDS.Client.start_export_task
    response_db_start_export_task = client.start_export_task(
        ExportTaskIdentifier=f"{product_name}-{env}-{today}-{id_generator()}",
        SourceArn= db_cluster_snapshots_arn,
        S3BucketName=s3_bucket_name,
        IamRoleArn=export_iam_role_arn,
        KmsKeyId=kms_key_arn,
        S3Prefix=f"dbexport"
    )

    return f"Running snapshots export on s3 {s3_bucket_name}."