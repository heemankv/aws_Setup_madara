get_queue_name() {
  echo "${SQS_QUEUE_NAME//\{\}/$1}"
}

# Create JobHandleFailure queue (DLQ)
JOB_HANDLE_FAILURE_QUEUE_NAME=$(get_queue_name "JobHandleFailure")
aws sqs create-queue --queue-name "${JOB_HANDLE_FAILURE_QUEUE_NAME}" \
  --attributes VisibilityTimeout=300 --region "${AWS_REGION}" --profile "$AWS_PROFILE_NAME"

JOB_HANDLE_FAILURE_QUEUE_URL=$(aws sqs get-queue-url --queue-name "${JOB_HANDLE_FAILURE_QUEUE_NAME}" --query 'QueueUrl' --output text --region "${AWS_REGION}" --profile "$AWS_PROFILE_NAME")
JOB_HANDLE_FAILURE_QUEUE_ARN=$(aws sqs get-queue-attributes --queue-url "${JOB_HANDLE_FAILURE_QUEUE_URL}" --attribute-names QueueArn --query 'Attributes.QueueArn' --output text --region "${AWS_REGION}" --profile "$AWS_PROFILE_NAME")

# Dynamically create redrive-policy.json
echo "Creating redrive-policy.json with DLQ ARN: ${JOB_HANDLE_FAILURE_QUEUE_ARN}"
cat <<EOF > redrive-policy.json
{
  "RedrivePolicy": "{\"deadLetterTargetArn\":\"${JOB_HANDLE_FAILURE_QUEUE_ARN}\",\"maxReceiveCount\":5}"
}
EOF
echo "redrive-policy.json created."

# Create WorkerTrigger queue
WORKER_TRIGGER_QUEUE_NAME=$(get_queue_name "WorkerTrigger")
aws sqs create-queue --queue-name "${WORKER_TRIGGER_QUEUE_NAME}" \
  --attributes VisibilityTimeout=300 --region "${AWS_REGION}" --profile "$AWS_PROFILE_NAME"

export WORKER_TRIGGER_QUEUE_URL=$(aws sqs get-queue-url --queue-name "${WORKER_TRIGGER_QUEUE_NAME}" --query 'QueueUrl' --output text --region "${AWS_REGION}" --profile "$AWS_PROFILE_NAME")
export WORKER_TRIGGER_QUEUE_ARN=$(aws sqs get-queue-attributes --queue-url "${WORKER_TRIGGER_QUEUE_URL}" --attribute-names QueueArn --query 'Attributes.QueueArn' --output text --region "${AWS_REGION}" --profile "$AWS_PROFILE_NAME")

# Create other queues with DLQ
QUEUE_TYPES=("SnosJobProcessing" "SnosJobVerification" "ProvingJobProcessing" "ProvingJobVerification" "ProofRegistrationJobProcessing" "ProofRegistrationJobVerification" "DataSubmissionJobProcessing" "DataSubmissionJobVerification" "UpdateStateJobProcessing" "UpdateStateJobVerification")
VISIBILITY_TIMEOUTS=(300 300 300 300 300 300 300 300 900 300)

for i in "${!QUEUE_TYPES[@]}"; do
  QUEUE_NAME=$(get_queue_name "${QUEUE_TYPES[$i]}")
  VISIBILITY_TIMEOUT="${VISIBILITY_TIMEOUTS[$i]}"
  
  aws sqs create-queue --queue-name "${QUEUE_NAME}" \
  --attributes VisibilityTimeout="${VISIBILITY_TIMEOUT}" \
  --output text \
  --region "${AWS_REGION}" --profile "$AWS_PROFILE_NAME"

  QUEUE_URL=$(aws sqs get-queue-url --queue-name "${QUEUE_NAME}" \
    --query 'QueueUrl' --output text --region "${AWS_REGION}" --profile "$AWS_PROFILE_NAME")
    
  aws sqs set-queue-attributes \
    --queue-url "${QUEUE_URL}" \
    --attributes file://redrive-policy.json \
    --region "${AWS_REGION}" \
    --output text \
    --profile "$AWS_PROFILE_NAME"
done
