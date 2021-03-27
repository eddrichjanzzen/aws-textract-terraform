import os
import boto3


def lambda_handler(event, context):
	
	if event:
		print("event: ", event)

		file_obj = event['Records'][0]
		filename = str(file_obj['s3']['object']['key'])

		bucket = os.environ['s3_bucket_name']
		document = filename

		client = boto3.client('textract')

		#process using S3 object
		response = client.detect_document_text(
				Document={
						'S3Object': {
								'Bucket': bucket, 
								'Name': document
						}
				}
		)

		#Get the text blocks
		blocks = response['Blocks']
		
		return {
				'statusCode': 200,
				'body': json.dumps(blocks)
		}           
