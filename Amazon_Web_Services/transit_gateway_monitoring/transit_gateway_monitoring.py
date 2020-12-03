import boto3
import csv
import os
import io
import datetime
import smtplib

from datetime import timedelta
from email.mime.multipart import MIMEMultipart
from email.mime.base import MIMEBase
from email import encoders

def main():
    metrics = pull_metrics()
    csv = build_csv(metrics)
    send_csv_to_s3(csv)
    email_csv(csv)

def pull_metrics():

    cloudwatch = boto3.client("cloudwatch")

    response = cloudwatch.get_metric_data(
    MetricDataQueries=[
        {
            'Id': 'm1',
            'MetricStat': {
                'Metric': {
                    'Namespace': 'AWS/TransitGateway',
                    'MetricName': 'BytesIn',
                    'Dimensions': [
                        {
                            'Name': 'TransitGateway',
                            'Value': 'tgw-0b3ded4e0ba2a7b7b'
                        }
                    ]
                },
                'Period': 300,
                'Stat': 'Average',
            }
        },
        {
            'Id': 'm2',
            'MetricStat': {
                'Metric': {
                    'Namespace': 'AWS/TransitGateway',
                    'MetricName': 'BytesOut',
                    'Dimensions': [
                        {
                            'Name': 'TransitGateway',
                            'Value': 'tgw-0b3ded4e0ba2a7b7b'
                        },
                    ]
                },
                'Period': 300,
                'Stat': 'Average',
            }
        },
        {
            'Id': 'm3',
            'MetricStat': {
                'Metric': {
                    'Namespace': 'AWS/TransitGateway',
                    'MetricName': 'PacketsIn',
                    'Dimensions': [
                        {
                            'Name': 'TransitGateway',
                            'Value': 'tgw-0b3ded4e0ba2a7b7b'
                        },
                    ]
                },
                'Period': 300,
                'Stat': 'Average',
            }
        },
        {
            'Id': 'm4',
            'MetricStat': {
                'Metric': {
                    'Namespace': 'AWS/TransitGateway',
                    'MetricName': 'PacketsOut',
                    'Dimensions': [
                        {
                            'Name': 'TransitGateway',
                            'Value': 'tgw-0b3ded4e0ba2a7b7b'
                        },
                    ]
                },
                'Period': 300,
                'Stat': 'Average',
            }
        },
        {
            'Id': 'm5',
            'MetricStat': {
                'Metric': {
                    'Namespace': 'AWS/TransitGateway',
                    'MetricName': 'PacketDropCountBlackhole',
                    'Dimensions': [
                        {
                            'Name': 'TransitGateway',
                            'Value': 'tgw-0b3ded4e0ba2a7b7b'
                        },
                    ]
                },
                'Period': 300,
                'Stat': 'Average',
            }
        },
        {
            'Id': 'm6',
            'MetricStat': {
                'Metric': {
                    'Namespace': 'AWS/TransitGateway',
                    'MetricName': 'PacketDropCountNoRoute',
                    'Dimensions': [
                        {
                            'Name': 'TransitGateway',
                            'Value': 'tgw-0b3ded4e0ba2a7b7b'
                        },
                    ]
                },
                'Period': 300,
                'Stat': 'Average',
            }
        }
    ],
    StartTime=datetime.datetime.utcnow() - timedelta(days=1),
    EndTime=datetime.datetime.utcnow(),
    ScanBy='TimestampAscending',
    )
    
    return response['MetricDataResults']

    # debugging
    # return list([{'Id': 'm1', 'Label': 'BytesIn', 'Timestamps': [0,0], 'Values': [0,0], 'StatusCode': 'Complete'}, {'Id': 'm2', 'Label': 'BytesOut', 'Timestamps': [0,0], 'Values': [0,0], 'StatusCode': 'Complete'}, {'Id': 'm3', 'Label': 'PacketsIn', 'Timestamps': [0,0], 'Values': [0,0], 'StatusCode': 'Complete'}, {'Id': 'm4', 'Label': 'PacketsOut', 'Timestamps': [0,0], 'Values': [0,0], 'StatusCode': 'Complete'}, {'Id': 'm5', 'Label': 'PacketDropCountBlackhole', 'Timestamps': [0,0], 'Values': [0,0], 'StatusCode': 'Complete'}, {'Id': 'm6', 'Label': 'PacketDropCountNoRoute', 'Timestamps': [0,0], 'Values': [0,0], 'StatusCode': 'Complete'}])


def build_csv(mertics):
    
    output = io.StringIO()

    # date = datetime.datetime.now()

    # local
    # with open("transit_gateway_monitoring_{}_{}_{}.csv".format(date.year, date.month, date.day), "w+") as csvfile:
        
    #     fieldnames = ["timestamp", "metric", "value"]
    #     writer = csv.writer(csvfile)

    #     writer.writerow(fieldnames)
        
    #     for metric in mertics:
    #         label = metric['Label']
    #         length = len(metric['Values'])
    #         for x in range(length):
    #             writer.writerow(['{}'.format(metric['Timestamps'][x]), 
    #                             '{}'.format(label), '{}'.format(metric['Values'][x])]) 
   
   
    # s3
    fieldnames = ["timestamp", "metric", "value"]
    writer = csv.writer(output)

    writer.writerow(fieldnames)
    
    for metric in mertics:
        label = metric['Label']
        length = len(metric['Values'])
        for x in range(length):
            writer.writerow(['{}'.format(metric['Timestamps'][x]), 
                            '{}'.format(label), '{}'.format(metric['Values'][x])])

    return output
        

def send_csv_to_s3(csv):

    date = datetime.datetime.now()
    bio = io.BytesIO(csv.getvalue().encode('utf8'))

    s3 = boto3.client('s3')

    try:
        s3.put_object(Key='{}/{}/{}/transit_gateway_monitoring.csv'.format(date.year, date.month, date.day), Bucket=os.environ['BUCKET_NAME'], Body=bio) 
        print("upload successful")
    except:
        print("upload unsuccessful")


def email_csv(csv):
    
    msg = MIMEMultipart()
    msg['Subject'] = 'Weekly Transit Gateway Monitoring'
    msg['From'] = '{}'.format(os.environ['FROM_EMAIL'])
    msg['To'] = '{}'.format(os.environ['TO_EMAIL'])

    part = MIMEBase('application', 'octet-stream')
    part.set_payload(csv.getvalue())
    encoders.encode_base64(part)
    part.add_header('Content-Disposition', "attachment; filename=transit_gateway_monitoring.csv")

    msg.attach(part)

    s = smtplib.SMTP_SSL('{}'.format(os.environ['SMTP_SERVER']), os.environ['SMTP_PORT'])
    s.login('{}'.format(os.environ['SMTP_LOGIN']), '{}'.format(os.environ['SMTP_PASSWORD']))
    s.sendmail('{}'.format(os.environ['FROM_EMAIL']), '{}'.format(os.environ['TO_EMAIL']), msg.as_string())
    s.quit()

main()
