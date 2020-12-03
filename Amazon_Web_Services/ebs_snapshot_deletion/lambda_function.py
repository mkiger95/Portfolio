import boto3
import json

from datetime import datetime, timedelta
from botocore.exceptions import ClientError

def lambda_handler(event, context):
    
    main()
    
    return {
        'statusCode': 200,
        'body': json.dumps('Last 24 hour snapshots have been deleted')
    }

def main():

    now = datetime.now()

    ec2 = boto3.client('ec2')

    regions = ec2.describe_regions().get('Regions', [])

    for region in regions:
        print("Checking region {}".format(region))
        reg = region['RegionName']

        ec2 = boto3.client('ec2', region_name=reg)

        result = ec2.describe_snapshots(OwnerIds=['self'])

        for snapshot in result['Snapshots']:
            snapshot_time = snapshot['StartTime'].replace(tzinfo=None)

            if(now-snapshot_time) > timedelta(1):

                try:
                    ec2resource = boto3.resource('ec2', region_name=reg)
                    snapshot_to_be_deleted = ec2resource.Snapshot(snapshot['SnapshotId'])
                    snapshot_to_be_deleted.delete()
                    print("Snapshot ID: {} has been deleted".format(snapshot['SnapshotId']))
                except ClientError as e:
                    print(e)