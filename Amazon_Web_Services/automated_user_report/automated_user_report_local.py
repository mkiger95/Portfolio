import boto3
import botocore.exceptions
import time
import io
import csv
import dateutil
import json
import jinja2
import smtplib
import os

from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
from operator import itemgetter
from datetime import datetime

def lambda_handler(event, context):
    
    main()
    
    return {
        'statusCode': 200,
        'body': json.dumps('Automated User Report Sent')
    }
    
def main():
    reports = get_reports()
    report_html, report_html_string = html_report(reports)
    # email_report(report_html)
    csv = build_csv(reports)
    send_files_to_s3(csv, report_html_string)

def get_reports():
    reports = list()

    iam = boto3.client("iam")

    complete = False
    while not complete:
        resp = iam.generate_credential_report()
        complete = resp["State"] == 'COMPLETE'
        time.sleep(1)
        
    report = iam.get_credential_report()
    report_csv = io.StringIO(report['Content'].decode('utf-8'))
    csv_reader = csv.DictReader(report_csv)

    users = list(csv_reader)
    
    reports.append({    'name' : 'AWS Account',
                'report' : list(map(add_user_properties, users))
            })

    return reports

def email_report(report_html,
                 report_plain='Unsupported Client. Please view with an Email Client that supports HTML.'):

    msg = MIMEMultipart('alternative')
    msg['Subject'] = 'Weekly Automated IAM User Report'
    msg['From'] = '{}'.format(os.environ['FROM_EMAIL'])
    msg['To'] = '{}'.format(os.environ['TO_EMAIL'])
    plain = MIMEText(report_plain, 'plain')
    html = MIMEText(report_html, 'html')

    msg.attach(plain)
    msg.attach(html)

    s = smtplib.SMTP_SSL('{}'.format(os.environ['SMTP_SERVER']), os.environ['SMTP_PORT'])
    s.login('{}'.format(os.environ['SMTP_LOGIN']), '{}'.format(os.environ['SMTP_PASSWORD']))
    s.sendmail('{}'.format(os.environ['FROM_EMAIL']), '{}'.format(os.environ['TO_EMAIL']), msg.as_string())
    s.quit()

def build_csv(reports):
    
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
    fieldnames = ["user", "last_active", "created", "access_keys", "password", "last_changed", "groups", "policies", "last_service_used_by_an_access_key"]
    writer = csv.writer(output)

    writer.writerow(fieldnames)
    
    for report in reports:
        for user in sorted(report['report'], key=itemgetter('user')):
            username = user['user']
            try:
                last_active_date = max(filter(None, [user['access_key_1_last_used_date'], user['access_key_2_last_used_date'], user['password_last_used']]))
                last_active = days_ago(last_active_date)
            except ValueError:
                last_active = 'never'
            created = days_ago(user['user_creation_time'])
            access_keys = 'true' if user['access_key_1_active'] or user['access_key_2_active'] else 'false'
            password = 'true' if user['password_enabled'] else 'false'
            if user['password_last_changed']:
                if user['user_creation_time'].date() == user['password_last_changed'].date():
                    last_changed = 'never'
                else:
                    last_changed = days_ago(user['password_last_changed'])
            else:
                last_changed = 'never'
            groups = ', '.join(user['groups'])
            policies = ', '.join(user['policies'])
            last_service_used = last_service(user)
            writer.writerow([username, last_active, created, access_keys, password, last_changed, groups, policies, last_service_used])
        
    return output

def send_files_to_s3(csv, html):

    date = datetime.now()
    bio_csv = io.BytesIO(csv.getvalue().encode('utf8'))
    bio_html = io.BytesIO(html.getvalue().encode('utf8'))

    s3 = boto3.client('s3')

    try:
        s3.put_object(Key='{}/{}/{}/weekly_user_report.csv'.format(date.year, date.month, date.day), Bucket=os.environ['BUCKET_NAME'], Body=bio_csv)

        #debugging
        #s3.put_object(Key='{}/{}/{}/weekly_user_report.csv'.format(date.year, date.month, date.day), Bucket='morgs-test-bucket', Body=bio_csv) 
        print("upload csv successful")
    except:
        print("upload csv unsuccessful")

    try:
        s3.put_object(Key='{}/{}/{}/weekly_user_report.html'.format(date.year, date.month, date.day), Bucket=os.environ['BUCKET_NAME'], Body=bio_html)

        #debugging
        #s3.put_object(Key='{}/{}/{}/weekly_user_report.html'.format(date.year, date.month, date.day), Bucket='morgs-test-bucket', Body=bio_html) 
        print("upload html successful")
    except:
        print("upload html unsuccessful")

def add_user_properties(user):
    datetime_keys = ['access_key_1_last_rotated', 'access_key_1_last_used_date', 'access_key_2_last_rotated',
                         'access_key_2_last_used_date', 'cert_1_last_rotated', 'cert_2_last_rotated',
                         'password_last_changed', 'password_last_used', 'password_next_rotation', 'user_creation_time']

    bool_keys = ['access_key_1_active', 'access_key_2_active', 'cert_1_active', 'cert_2_active', 'mfa_active',
                    'password_enabled']

    str_keys = ['access_key_1_last_used_region', 'access_key_1_last_used_service', 'access_key_2_last_used_region',
                'access_key_2_last_used_service']

    err_vals = ['N/A', 'no_information', 'not_supported']

    for key in datetime_keys:
        try:
            user[key] = dateutil.parser.parse(user[key]).replace(tzinfo=None) if user[key] not in err_vals else None
        except Exception as e:
            print("error")
            #self.log.error('Failed to parse date {}'.format(user[key]))

    for key in bool_keys:
        user[key] = user[key] == 'true'

    if user['user'] == '<root_account>':
        user['password_enabled'] = True

    for key in str_keys:
        if user[key] in err_vals:
            user[key] = None

    user['groups'] = list()
    user['policies'] = list()
    try:
        user['groups'] = user_groups(user['user'])
        user['policies'] = user_policies(user['user'])
    except botocore.exceptions.ClientError as e:
        if '(NoSuchEntity)' in str(e):
            user['user'] += ' [DELETED]'
            pass
        else:
            raise

    return user

def user_groups(user):
    if user == '<root_account>':
        return []
    #self.log.debug('Fetching Groups for user {}'.format(user))
    iam = boto3.client('iam')
    complete = False
    marker = None
    ui = []
    while not complete:
        if marker:
            items = iam.list_groups_for_user(UserName=user, Marker=marker)
        else:
            items = iam.list_groups_for_user(UserName=user)
        if items['IsTruncated']:
            marker = items['Marker']
        else:
            complete = True

        for group in items['Groups']:
            ui.append(group['GroupName'])
    return ui

def user_policies(user):
    if user == '<root_account>':
        return []
    #self.log.debug('Fetching Policies for user {}'.format(user))
    iam = boto3.client('iam')
    complete = False
    marker = None
    ui = []
    while not complete:
        if marker:
            items = iam.list_user_policies(UserName=user, Marker=marker)
        else:
            items = iam.list_user_policies(UserName=user)
        if items['IsTruncated']:
            marker = items['Marker']
        else:
            complete = True

        ui.extend(items['PolicyNames'])
    return ui

def html_report(reports):
    page_template = """<!doctype html>
    <html lang="en">
    <head>
        <meta charset="utf-8">
        <title>AWS User Report</title>
    </head>
    {{ header }}
    <body style="font-family:'Source Sans Pro','Helvetica Neue',Helvetica,Arial,sans-serif;font-style:normal;font-weight:400;text-transform:none;text-shadow:none;text-decoration:none;text-rendering:optimizelegibility;color: #000000;">
        {{ body }}
    </body>
    {{ footer }}
    </html>
    """
    html_reports = list()
    html = jinja2.Template(page_template)
    for report in reports:
        html_reports.append(report2html(report['name'], report['report']))

    #log.debug('Assembling final HTML report')
    html.render(body='<br/><br/><br/>'.join(html_reports))
    return html, io.StringIO(html_reports[0])

def report2html(name, report):
    img = {'n/a': '&#x2796;',
           'never': '&#x2716;',
           'true': '&#x2714;',
           'false': '&#x2796;'
           }

    # Need to duplicate style elements for certain Email clients
    report_template = """    <h3>{{ name }}</h3>
    <table style="border: 1px solid black;border-collapse: collapse;">
        <tr class="center">
            <td style="padding-left: 3px; padding-right: 3px;border: 1px solid black;border-collapse: collapse;"><b>User</b></td>
            <td style="padding-left: 3px; padding-right: 3px;border: 1px solid black;border-collapse: collapse;"><b>Last active</b></td>
            <td style="padding-left: 3px; padding-right: 3px;border: 1px solid black;border-collapse: collapse;"><b>Created</b></td>
            <td style="padding-left: 3px; padding-right: 3px;border: 1px solid black;border-collapse: collapse;"><b>Access Key(s)</b></td>
            <td style="padding-left: 3px; padding-right: 3px;border: 1px solid black;border-collapse: collapse;"><b>Password</b></td>
            <td style="padding-left: 3px; padding-right: 3px;border: 1px solid black;border-collapse: collapse;"><b>Last changed</b></td>
            <td style="padding-left: 3px; padding-right: 3px;border: 1px solid black;border-collapse: collapse;"><b>Groups</b></td>
            <td style="padding-left: 3px; padding-right: 3px;border: 1px solid black;border-collapse: collapse;"><b>Policies</b></td>
            <td style="padding-left: 3px; padding-right: 3px;border: 1px solid black;border-collapse: collapse;"><b>Last Service used by an Access Key</b></td>
        </tr>
        {%- for row in rows %}
        <tr style="background-color: {{ row.color }}">
            <td style="padding-left: 3px; padding-right: 3px;border: 1px solid black;border-collapse: collapse;white-space:nowrap">{{ row.user|e }}</td>
            <td style="padding-left: 3px; padding-right: 3px;border: 1px solid black;border-collapse: collapse;white-space:nowrap; text-align: {{ row.active_align }};">{{ row.active }}</td>
            <td style="padding-left: 3px; padding-right: 3px;border: 1px solid black;border-collapse: collapse;white-space:nowrap; text-align: right;">{{ row.created }}</td>
            <td style="padding-left: 3px; padding-right: 3px;border: 1px solid black;border-collapse: collapse;text-align: center;">{{ row.access_key }}</td>
            <td style="padding-left: 3px; padding-right: 3px;border: 1px solid black;border-collapse: collapse;text-align: center;">{{ row.password }}</td>
            <td style="padding-left: 3px; padding-right: 3px;border: 1px solid black;border-collapse: collapse;white-space:nowrap; text-align: {{ row.password_changed_align }};">{{ row.password_changed }}</td>
            <td style="padding-left: 3px; padding-right: 3px;border: 1px solid black;border-collapse: collapse;">{{ row.groups }}</td>
            <td style="padding-left: 3px; padding-right: 3px;border: 1px solid black;border-collapse: collapse;">{{ row.policies }}</td>
            <td style="padding-left: 3px; padding-right: 3px;border: 1px solid black;border-collapse: collapse;">{{ row.last_service }}</td>
        </tr>
        {%- endfor %}
    </table>
"""
    rows = list()
    # we get a gradient from green over yellow to red and then
    # mix it with white to make it easy on the eyes
    mix_color = (255, 255, 255)
    color_gradient = color_mix(gyr_gradient(), mix_color)

    # how many days after account creation before
    # an account that never logged in is considered dead
    initial_wait_days = 60
    alert_days = 365  # anything after this will be considered dead

    for user in sorted(report, key=itemgetter('user')):
        r = {
            'user': user['user'],
            'active': '',
            'active_align': 'right',
            'created': '',
            'access_key': '',
            'password': '',
            'password_changed': '',
            'password_changed_align': 'right',
            'groups': ', '.join(user['groups']),
            'policies': ', '.join(user['policies']),
            'last_service': '',
            'color': '#{:02x}{:02x}{:02x}'.format(*color_gradient[-1])
        }
        try:
            last_active = max(filter(None, [user['access_key_1_last_used_date'], user['access_key_2_last_used_date'],
                                            user['password_last_used']]))
            r['active'] = days_ago(last_active)
            last_active_days = (datetime.utcnow() - last_active).days
            color_index = round(remap(last_active_days, 0, alert_days, 0, len(color_gradient)-1))
            r['color'] = '#{:02x}{:02x}{:02x}'.format(*color_gradient[color_index])
        except ValueError:
            r['active'] = img['never']
            r['active_align'] = 'center'

        if user['user'] == '<root_account>':
            r['color'] = '#{:02x}{:02x}{:02x}'.format(*color_gradient[0])

        if (datetime.utcnow() - user['user_creation_time']).days < initial_wait_days:
            r['color'] = '#{:02x}{:02x}{:02x}'.format(*color_gradient[0])

        if user['password_last_changed']:
            if user['user_creation_time'].date() == user['password_last_changed'].date():
                r['password_changed_align'] = 'center'
                r['password_changed'] = img['never']
            else:
                r['password_changed'] = days_ago(user['password_last_changed'])
        else:
            r['password_changed_align'] = 'center'
            r['password_changed'] = img['never'] if user['password_enabled'] else img['n/a']

        r['created'] = days_ago(user['user_creation_time'])

        r['access_key'] = img['true'] if user['access_key_1_active'] or user['access_key_2_active'] else img['false']
        r['password'] = img['true'] if user['password_enabled'] else img['false']
        r['last_service'] = last_service(user)

        rows.append(r)
    html = jinja2.Template(report_template)
    #log.debug('Creating HTML report snippet')
    return html.render(rows=rows, name=name)


def last_service(user):
    compare = False
    key_1 = False
    key_2 = False
    if user['access_key_1_last_used_date'] and user['access_key_2_last_used_date']:
        compare = True
    if user['access_key_1_last_used_service'] \
            and user['access_key_1_last_used_region'] \
            and user['access_key_1_last_used_date']:
        key_1 = True
    if user['access_key_2_last_used_service'] \
            and user['access_key_2_last_used_region'] \
            and user['access_key_2_last_used_date']:
        key_2 = True

    if compare and key_1 and key_2:
        if user['access_key_1_last_used_date'] > user['access_key_2_last_used_date']:
            last_service_str = '{} in {}, {}'.format(user['access_key_1_last_used_service'],
                                                     user['access_key_1_last_used_region'],
                                                     days_ago(user['access_key_1_last_used_date']))
        else:
            last_service_str = '{} in {}, {}'.format(user['access_key_2_last_used_service'],
                                                     user['access_key_2_last_used_region'],
                                                     days_ago(user['access_key_2_last_used_date']))
    elif key_1:
        last_service_str = '{} in {}, {}'.format(user['access_key_1_last_used_service'],
                                                 user['access_key_1_last_used_region'],
                                                 days_ago(user['access_key_1_last_used_date']))

    elif key_2:
        last_service_str = '{} in {}, {}'.format(user['access_key_2_last_used_service'],
                                                 user['access_key_2_last_used_region'],
                                                 days_ago(user['access_key_2_last_used_date']))
    else:
        last_service_str = ''

    return last_service_str


def days_ago(dt):
    now = datetime.utcnow()
    days = (now - dt).days
    if days == 0:
        return 'today'
    elif days == 1:
        return 'yesterday'
    else:
        return '{} days ago'.format(days)


def color_mix(in_color, mix_color):
    def mix(in_color, mix_color):
        return tuple(round(sum(x) / 2) for x in zip(in_color, mix_color))
    if isinstance(in_color, list):
        out_colors = list()
        for color in in_color:
            out_colors.append(mix(color, mix_color))
        return out_colors
    else:
        return mix(in_color, mix_color)


def gyr_gradient(increment=1):
    r = 0
    g = 255
    b = 0
    gradient = list()
    gradient.append((r, g, b))

    if increment < 1:
        increment = 1
    elif increment > 255:
        increment = 255
    while r < 255:
        r += increment
        if r > 255:
            r = 255
        gradient.append((r, g, b))
    while g > 0:
        g -= increment
        if g < 0:
            g = 0
        gradient.append((r, g, b))
    return gradient


def remap(x, in_min, in_max, out_min, out_max, min_max_cutoff=True):
    if min_max_cutoff:
        if x < in_min:
            x = in_min
        elif x > in_max:
            x = in_max
    return (x - in_min) * (out_max - out_min) / (in_max - in_min) + out_min


class ReportEncoder(json.JSONEncoder):
    def default(self, o):
        if isinstance(o, datetime):
            return o.isoformat()
        return super().default(self, o)

main()