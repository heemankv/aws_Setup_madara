# AWS Resource Setup for Madara Orchestrator

This repository contains scripts to set up the necessary AWS resources for the Madara Orchestrator.

## Prerequisites

*   AWS CLI installed and configured with necessary permissions.
*   Ensure the `default-mfa` profile is configured in your AWS CLI, or modify the scripts to use your preferred profile.
*   Required environment variables for base configuration (like `MADARA_ORCHESTRATOR_AWS_PREFIX`, `AWS_REGION`, etc.) should be reviewed in `env_setup.sh` and adjusted if necessary before the first run.

## Setup

To set up all resources, simply run the master script:

```bash
bash ./master_setup.sh
```

This script will:
1.  Set up environment variables (including fetching the AWS Account ID).
2.  Create an S3 bucket.
3.  Create necessary SQS queues (including a DLQ and a worker trigger queue, and dynamically generating the redrive policy).
4.  Set up IAM roles and policies (dynamically generating the EventBridge SQS policy).
5.  Configure cron jobs (EventBridge scheduled rules).
6.  Create an SNS topic for alerts.

The script will output progress and any errors encountered.
