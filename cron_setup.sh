# Generate schedule expression
INTERVAL_SECONDS=${MADARA_ORCHESTRATOR_EVENT_BRIDGE_INTERVAL_SECONDS}
if (( INTERVAL_SECONDS == 60 )); then
  SCHEDULE_EXPRESSION="rate(1 minute)"
elif (( INTERVAL_SECONDS < 60 )); then
  SCHEDULE_EXPRESSION="rate(${INTERVAL_SECONDS} seconds)"
else
  MINUTES=$((INTERVAL_SECONDS / 60))
  SCHEDULE_EXPRESSION="rate(${MINUTES} minutes)"
fi

WORKER_TRIGGERS=("Snos" "Proving" "ProofRegistration" "DataSubmission" "UpdateState" "Batching")

for TRIGGER_TYPE in "${WORKER_TRIGGERS[@]}"; do
  RULE_NAME="${EB_RULE_NAME_BASE}-${TRIGGER_TYPE}"

  aws scheduler create-schedule --name "${RULE_NAME}" --group-name "default" \
    --schedule-expression "${SCHEDULE_EXPRESSION}" \
    --schedule-expression-timezone "UTC" \
    --flexible-time-window '{"Mode":"OFF"}' \
    --target "{\"Arn\":\"${WORKER_TRIGGER_QUEUE_ARN}\",\"RoleArn\":\"${EB_ROLE_ARN}\",\"Input\":\"\\\"${TRIGGER_TYPE}\\\"\"}" \
    --state ENABLED --region "${AWS_REGION}" --profile default-mfa
done