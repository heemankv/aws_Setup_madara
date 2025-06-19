#!/bin/bash

# Madara Orchestrator Configuration Script
# This script sets up environment variables for the Madara Orchestrator AWS resources

# Base configuration
export MADARA_ORCHESTRATOR_AWS_PREFIX="karnot"
export MADARA_ORCHESTRATOR_AWS_S3_BUCKET_IDENTIFIER="karnot-orchestrator-bucket"
export MADARA_ORCHESTRATOR_AWS_SQS_QUEUE_IDENTIFIER_TEMPLATE="karnot_orchestrator_{}_queue"
export MADARA_ORCHESTRATOR_AWS_SNS_TOPIC_IDENTIFIER="karnot-orchestrator-alerts"
export MADARA_ORCHESTRATOR_EVENT_BRIDGE_TYPE="Schedule"
export MADARA_ORCHESTRATOR_EVENT_BRIDGE_INTERVAL_SECONDS="60"
export AWS_REGION="ap-south-1"

# Derived configuration
export S3_BUCKET_NAME="${MADARA_ORCHESTRATOR_AWS_PREFIX}-${MADARA_ORCHESTRATOR_AWS_S3_BUCKET_IDENTIFIER}"
export SNS_TOPIC_NAME="${MADARA_ORCHESTRATOR_AWS_PREFIX}_${MADARA_ORCHESTRATOR_AWS_SNS_TOPIC_IDENTIFIER}"
export EB_ROLE_NAME_BASE="${MADARA_ORCHESTRATOR_AWS_PREFIX}-karnot-wt-role"
export EB_POLICY_NAME_BASE="${MADARA_ORCHESTRATOR_AWS_PREFIX}-karnot-wt-policy"
export EB_RULE_NAME_BASE="${MADARA_ORCHESTRATOR_AWS_PREFIX}-karnot-wt-rule"

echo "Environment variables set successfully!"
echo "S3 Bucket Name: $S3_BUCKET_NAME"
echo "SNS Topic Name: $SNS_TOPIC_NAME"
echo "AWS Region: $AWS_REGION"