import os
import boto3
import json

def lambda_handler(event, context):

	if event:
		print('Event Data :', str(event))
		for record in event['Records']:
			payload = json.loads(record['body'])

			print('S3 Event Payload :', str(payload))
			file_obj = payload['Records'][0]		
			client = boto3.client('textract')
			
			s3bucket = os.environ['s3_bucket_name']
			filename = str(file_obj['s3']['object']['key'])

			#process using S3 object
			response = client.detect_document_text(
				Document={
					'S3Object': {
							'Bucket': s3bucket, 
							'Name': filename
					}
				}
			)

			#Get the text blocks
			blocks = response['Blocks']

			print('Textract Data :', str(blocks))

			return {
				'statusCode': 200,
				'body': json.dumps(blocks)
			}           
