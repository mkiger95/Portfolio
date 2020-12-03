import boto3
import os
import datetime
import json

from datetime import timedelta

def lambda_handler(event, context):

    main()
    
    return {
        'statusCode': 200,
        'body': json.dumps('Cloudtrail Logs Groups Copied')
    }

def main():

    metrics = list()
    sessions = json.loads(os.environ['SESSIONS'])

    for session in sessions:
        newsession_id, newsession_key, newsession_token, newsession_arn = assume_role(session)
        metrics = pull_metrics(newsession_id, newsession_key, newsession_token, newsession_arn, metrics)
    
    copy_metrics(metrics)

def assume_role(session):

    sts = boto3.client("sts")

    sts_response = sts.assume_role(
        RoleArn = '{}'.format(session),
        RoleSessionName = 'newsession'
    )

    return sts_response['Credentials']['AccessKeyId'], sts_response['Credentials']['SecretAccessKey'], sts_response['Credentials']['SessionToken'], sts_response['AssumedRoleUser']['Arn']

def pull_metrics(newsession_id, newsession_key, newsession_token, newsession_arn, metrics):

    all_streams = []
    logGroupName = os.environ['LOGGROUPNAME']

    logs = boto3.client(
        'logs',
        region_name='{}'.format(os.environ['REGION']),
        aws_access_key_id=newsession_id,
        aws_secret_access_key=newsession_key,
        aws_session_token=newsession_token
    )

    response = logs.describe_log_streams(logGroupName=logGroupName)
    all_streams += response['logStreams']
    stream_names = [stream['logStreamName'] for stream in all_streams]

    for stream in stream_names:
        events = list()
        metric = {}

        metric['logGroupName'] = logGroupName
        metric['logStreamName'] = '{}'.format(stream)

        response = logs.get_log_events(
            logGroupName = logGroupName,
            logStreamName = '{}'.format(stream),
            startTime = int((datetime.datetime.now() - timedelta(minutes=10)).timestamp()) * 1000,
            endTime = int((datetime.datetime.now().timestamp())) * 1000
        )

        for event in response['events']:
            events.append({'timestamp' : event['timestamp'], 'message' : event['message']})

        metric['logEvents'] = events


        metrics.append(metric)

    return metrics

def copy_metrics(metrics):

    logs = boto3.client("logs")
    
    for metric in metrics:
        try:
            logs.create_log_stream(
                logGroupName = metric['logGroupName'],
                logStreamName = metric['logStreamName']
            )

            response = logs.put_log_events(
                logGroupName = metric['logGroupName'],
                logStreamName = metric['logStreamName'],
                logEvents=metric['logEvents']
            )
        except logs.exceptions.ResourceAlreadyExistsException:
            for event in metric['logEvents']:
                response = logs.describe_log_streams(
                    logGroupName = metric['logGroupName'],
                    logStreamNamePrefix = metric['logStreamName']
                )
                
                streamSequenceToken = response['logStreams'][0]['uploadSequenceToken']
                tempList = list()
                tempList.append(event)

                try:
                    response = logs.put_log_events(
                            logGroupName = metric['logGroupName'],
                            logStreamName = metric['logStreamName'],
                            logEvents = tempList,
                            sequenceToken = streamSequenceToken
                    )
                except logs.exceptions.InvalidSequenceTokenException as e:

                    response = logs.describe_log_streams(
                        logGroupName = metric['logGroupName'],
                        logStreamNamePrefix = metric['logStreamName']
                    )
                
                    streamSequenceToken = response['logStreams'][0]['uploadSequenceToken']

                    response = logs.put_log_events(
                            logGroupName = metric['logGroupName'],
                            logStreamName = metric['logStreamName'],
                            logEvents = tempList,
                            sequenceToken = streamSequenceToken
                    )



