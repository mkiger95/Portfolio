import boto3
import json
import os

def lambda_handler(event, context):
    
    print(event)

    main(event)
    
    return {
        'statusCode': 200,
        'body': json.dumps('ebs volume attached')
    }

def main(event):

    ec2 = boto3.client("ec2")

    response = ec2.attach_volume(
        Device = '/dev/xvdf',
        InstanceId = event['detail']['instance-id'],
        VolumeId = '{}'.format(os.environ['VOLUME_ID']),
    )