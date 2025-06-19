#!/bin/bash

# Master setup script for Madara Orchestrator AWS resources
# This script orchestrates the execution of individual setup scripts.

set -e
set -o pipefail

# Helper function to log script execution steps
log_step() {
  echo "--------------------------------------------------"
  echo "$1"
  echo "--------------------------------------------------"
}

# Source environment variables
log_step "Sourcing environment variables from env_setup.sh..."
source ./env_setup.sh
if [ $? -ne 0 ]; then
    echo "Error sourcing env_setup.sh. Exiting."
    exit 1
fi
echo "Environment variables sourced successfully."
echo "AWS Account ID: ${AWS_ACCOUNT_ID}" # Verify AWS_ACCOUNT_ID is available
echo "AWS Region: ${AWS_REGION}"         # Verify AWS_REGION is available

# Execute S3 setup
log_step "Running s3_setup.sh..."
bash ./s3_setup.sh
if [ $? -ne 0 ]; then
    echo "Error during s3_setup.sh. Exiting."
    exit 1
fi
echo "s3_setup.sh completed successfully."

# Execute SQS setup
log_step "Running sqs_setup.sh (sourcing)..."
source ./sqs_setup.sh
if [ $? -ne 0 ]; then
    echo "Error during sqs_setup.sh. Exiting."
    exit 1
fi
echo "sqs_setup.sh completed successfully."
echo "Worker Trigger Queue URL: ${WORKER_TRIGGER_QUEUE_URL}"
echo "Worker Trigger Queue ARN: ${WORKER_TRIGGER_QUEUE_ARN}"

# Execute IAM setup
log_step "Running iam_setup.sh (sourcing)..."
source ./iam_setup.sh
if [ $? -ne 0 ]; then
    echo "Error during iam_setup.sh. Exiting."
    exit 1
fi
echo "iam_setup.sh completed successfully."
echo "EventBridge Policy ARN: ${EB_POLICY_ARN}"
echo "EventBridge Role ARN: ${EB_ROLE_ARN}"

# Execute Cron setup (EventBridge)
log_step "Running cron_setup.sh..."
bash ./cron_setup.sh
if [ $? -ne 0 ]; then
    echo "Error during cron_setup.sh. Exiting."
    exit 1
fi
echo "cron_setup.sh completed successfully."

# Execute SNS setup
log_step "Running sns_setup.sh..."
bash ./sns_setup.sh
if [ $? -ne 0 ]; then
    echo "Error during sns_setup.sh. Exiting."
    exit 1
fi
echo "sns_setup.sh completed successfully."

log_step "All setup scripts executed successfully!"
echo "Madara Orchestrator AWS resource setup complete."
