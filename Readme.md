source env_setup.sh


sh s3_setup.sh     
{
    "Location": "http://karnot-karnot-orchestrator-bucket.s3.amazonaws.com/"
}


sh sqs_setup.sh

then export WORKER_TRIGGER_QUEUE_ARN

then 

sh iam_setup.sh

