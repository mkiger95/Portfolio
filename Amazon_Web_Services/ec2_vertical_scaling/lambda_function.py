import boto3
import json

def lambda_handler(event, context):
    
    main()
    
    return {
        'statusCode': 200,
        'body': json.dumps('EC2 instances have been vertically scaled')
    }

def main():
    client = boto3.client('ec2')

    # Get t2.micro instances
    response = client.describe_instances(
    Filters=[{'Name': 'instance-type','Values':['t2.micro']}]
    )

    for r in response['Reservations']:
        instances = [i['InstanceId'] for i in r['Instances']]

    # Stop the instances
    client.stop_instances(InstanceIds=instances)
    waiter = client.get_waiter('instance_stopped')
    waiter.wait(InstanceIds=instances)

    # Change the instance type
    for i in instances:
        client.modify_instance_attribute(InstanceId=i, Attribute='instanceType', Value='m3.xlarge')

    # Start the instance
    client.start_instances(InstanceIds=instances)