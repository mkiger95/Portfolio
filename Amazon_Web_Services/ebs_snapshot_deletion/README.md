1. create a lambda function and make the role has the below permissions
```
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "logs:CreateLogGroup",
            "Resource": "arn:aws:logs:us-west-1:619671996086:*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            "Resource": [
                "arn:aws:logs:us-west-1:619671996086:log-group:/aws/lambda/ebs_snapshot_deletion:*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "ec2:Describe*",
                "ec2:DeleteSnapshot"
            ],
            "Resource": [
                "*"
            ]
        }
    ]
}
```

2. copy and paste the code from `lambda_function.py` into the code section of the lambda
3. setup a cloudwatch event to trigger every 24 hours which in turn triggers the lambda function
4. update the timeout time of the lambda function to 5 mintues (should never get close to taking that long)

Note all snapshots failed to be deleted will be logged