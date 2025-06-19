MANUAL_SUFFIX=$(openssl rand -base64 32 | tr -dc A-Za-z0-9 | head -c 4)
export EB_POLICY_NAME="${EB_POLICY_NAME_BASE}-${MANUAL_SUFFIX}"
export EB_ROLE_NAME="${EB_ROLE_NAME_BASE}-${MANUAL_SUFFIX}"

# Create policy document
cat <<EOF > eventbridge-sqs-policy.json
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Action": "sqs:SendMessage",
    "Resource": "${WORKER_TRIGGER_QUEUE_ARN}"
  }]
}
EOF

# Create policy
aws iam create-policy --policy-name "${EB_POLICY_NAME}" \
  --policy-document file://eventbridge-sqs-policy.json --profile default-mfa

export EB_POLICY_ARN=$(aws iam list-policies --scope Local --query "Policies[?PolicyName=='${EB_POLICY_NAME}'].Arn" --output text --profile default-mfa)

# Create trust policy
cat <<EOF > eventbridge-trust-policy.json
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Principal": {
      "Service": ["events.amazonaws.com", "scheduler.amazonaws.com"]
    },
    "Action": "sts:AssumeRole"
  }]
}
EOF

# Create role
aws iam create-role --role-name "${EB_ROLE_NAME}" \
  --assume-role-policy-document file://eventbridge-trust-policy.json \
  --region "${AWS_REGION}" --profile default-mfa

export EB_ROLE_ARN=$(aws iam get-role --role-name "${EB_ROLE_NAME}" --query 'Role.Arn' --output text --profile default-mfa)

# Attach policy to role
aws iam attach-role-policy --role-name "${EB_ROLE_NAME}" --policy-arn "${EB_POLICY_ARN}" --profile default-mfa
