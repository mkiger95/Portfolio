# automated report made to run in lambda within aws
    envirnoment variables needed:
        **TO_EMAIL, FROM_EMAIL, SMTP_SERVER, SMTP_PORT, SMTP_LOGIN, SMTP_PASSWORD, BUCKET_NAME**
    cloudwatch is then setup to trigger the event for the desire time (i.e. weekly)