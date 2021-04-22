# Terraform module to provision document processing with textract

## Prerequisites
Provision an S3 bucket to store Terraform State and DynamoDB for state-lock
using https://github.com/jrdalino/aws-tfstate-backend-terraform

## Usage
- Replace variables in terraform.tfvars
- Replace variables in state_config.tf
- Initialize, Review Plan and Apply
```
$ terraform init
$ terraform plan
$ terraform apply
```


## Architecture

Architecture below shows overall workflow and few additional components that are used in addition to the core architecture described above to process incoming documents as well as large backfill.

![](arch-complete.png)

### Process Sync Documents workflow
1. A document gets uploaded to an Amazon S3 bucket. It triggers a Lambda function which writes a task to process the document to DynamoDB.
2. Using DynamoDB streams, a Lambda function is triggered which writes to an SQS queue in one of the pipelines.
3. Documents are processed as described above by "Image Pipeline" or "Image and PDF Pipeline".
4. The processed data is stored in an S3 bucket.

## Source code

- [s3batchproc.py](./src/s3batchproc.py) Lambda function that handles event from S3 Batch operation job.
- [s3proc.py](./src/s3proc.py) Lambda function that handles s3 event for an object creation.
- [docproc.py](./src/docproc.py) Lambda function that push documents to queues for sync or async pipelines.
- [syncproc.py](./src/syncproc.py) Lambda function that takes documents from a queue and process them using sync APIs.
- [asyncproc.py](./src/asyncproc.py) Lambda function that takes documents from a queue and start async Amazon Textract jobs.
- [jobresults.py](./src/jobresults.py) Lambda function that process results for a completed Amazon Textract async job.
