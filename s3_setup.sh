source ./env_setup.sh

if [ "${AWS_REGION}" == "us-east-1" ]; then
  aws s3api create-bucket --bucket "${S3_BUCKET_NAME}" --region "${AWS_REGION}" --profile "$AWS_PROFILE_NAME"
else
  aws s3api create-bucket --bucket "${S3_BUCKET_NAME}" --region "${AWS_REGION}" \
    --create-bucket-configuration LocationConstraint="${AWS_REGION}" --profile "$AWS_PROFILE_NAME"
fi
