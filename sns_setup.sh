source ./env_setup.sh

aws sns create-topic --name "${SNS_TOPIC_NAME}" --region "${AWS_REGION}" --profile "$AWS_PROFILE_NAME"
