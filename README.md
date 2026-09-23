# AWS Project: Serverless File Conversion

Event-driven markdown pipeline with Floci and Terraform:

1. a markdown file lands in the upload bucket;
2. S3 publishes the event to an SNS topic, which fans out to two SQS queues;
3. the sentiment analysis Lambda calls Comprehend and stores the result in DynamoDB;
4. the conversion Lambda renders the markdown to HTML and stores it in the destination bucket.

## Prerequisites

- Docker
- Terraform 1.5+
- AWS CLI
- Python 3.12+ with `pip` on PATH (used by Terraform to vendor the `markdown` dependency for the conversion Lambda)

## Start Floci

```bash
docker compose up -d
```

## Apply Terraform

```bash
terraform init
terraform apply
```

## Architecture

<div style="margin: 1.5rem 0 1rem; padding: 1.25rem; border: 1px solid rgba(45,49,66,0.14); border-radius: 12px; background: #f5f5f5; overflow-x: auto;">
<div style="display: flex; align-items: center; gap: 0.65rem; margin-bottom: 0.45rem;">
	<img src="../icons/Architecture-Group-Icons_07312026/AWS-Cloud-logo_32.svg" alt="AWS cloud icon" style="width: 30px; height: 30px; display: block;" />
	<div style="font-family: 'Geist Mono', ui-monospace, monospace; font-size: 0.72rem; letter-spacing: 0.16em; text-transform: uppercase; color: #4f5d75;">AWS Architecture</div>
</div>
<div style="font-family: 'Instrument Serif', Georgia, serif; font-size: 1.85rem; line-height: 1.1; color: #2d3142; margin-bottom: 0.35rem;">Serverless File Conversion</div>
<div style="font-family: 'Geist Mono', ui-monospace, monospace; font-size: 0.72rem; letter-spacing: 0.14em; text-transform: uppercase; color: #4f5d75; margin-bottom: 1rem;">A markdown upload fans out through SNS into a sentiment analysis lane and a markdown-to-HTML conversion lane</div>

<table style="width: 100%; min-width: 1080px; border-collapse: collapse; table-layout: fixed;">
	<tr>
		<td colspan="3"></td>
		<td></td>
		<td style="text-align: center; padding-bottom: 0.3rem;">
			<div style="background: #ffffff; border: 1px solid rgba(45,49,66,0.18); border-radius: 12px; padding: 0.55rem 0.8rem; display: inline-flex; align-items: center; gap: 0.5rem;">
				<img src="../icons/Architecture-Service-Icons_07312026/Arch_Artificial-Intelligence/48/Arch_Amazon-Comprehend_48.svg" alt="Comprehend icon" style="width: 30px; height: 30px; display: block;" />
				<div style="font-family: 'Geist Mono', ui-monospace, monospace; font-size: 0.68rem; color: #2d3142; font-weight: 600;">Comprehend</div>
			</div>
		</td>
		<td colspan="2"></td>
	</tr>
	<tr>
		<td colspan="3"></td>
		<td></td>
		<td style="text-align: center; padding: 0.1rem 0;">
			<div style="width: 1px; height: 20px; background: #eb6c36; margin: 0 auto; position: relative;">
				<div style="position: absolute; top: -1px; left: -4px; width: 0; height: 0; border-bottom: 7px solid #eb6c36; border-left: 4px solid transparent; border-right: 4px solid transparent;"></div>
				<div style="position: absolute; bottom: -1px; left: -4px; width: 0; height: 0; border-top: 7px solid #eb6c36; border-left: 4px solid transparent; border-right: 4px solid transparent;"></div>
			</div>
		</td>
		<td colspan="2"></td>
	</tr>
	<tr>
		<td rowspan="3" style="vertical-align: middle; width: 15%; padding: 0 0.4rem;">
			<div style="background: #ffffff; border: 1px solid rgba(45,49,66,0.18); border-radius: 12px; padding: 0.75rem; text-align: center;">
				<div style="display: flex; justify-content: center; margin-bottom: 0.5rem;">
					<img src="../icons/Resource-Icons_07312026/Res_General-Icons/Res_48_Light/Res_Client_48_Light.svg" alt="Client icon" style="width: 32px; height: 32px; display: block; filter: invert(28%) sepia(9%) saturate(1077%) hue-rotate(176deg);" />
				</div>
				<div style="font-family: 'Geist', system-ui, sans-serif; font-size: 0.85rem; font-weight: 600; color: #2d3142;">File Upload</div>
			</div>
			<div style="text-align: center; margin: 0.35rem 0;">↓</div>
			<div style="background: #ffffff; border: 1px solid rgba(45,49,66,0.18); border-radius: 12px; padding: 0.75rem; text-align: center;">
				<div style="display: flex; justify-content: center; margin-bottom: 0.5rem;">
					<img src="../icons/Resource-Icons_07312026/Res_Storage/Res_Amazon-Simple-Storage-Service_Bucket_48.svg" alt="S3 icon" style="width: 32px; height: 32px; display: block;" />
				</div>
				<div style="display: inline-block; font-family: 'Geist Mono', ui-monospace, monospace; font-size: 0.6rem; letter-spacing: 0.08em; color: #4f5d75; border: 1px solid rgba(79,93,117,0.35); border-radius: 4px; padding: 0.08rem 0.3rem; margin-bottom: 0.2rem;">S3</div>
				<div style="font-family: 'Geist', system-ui, sans-serif; font-size: 0.85rem; font-weight: 600; color: #2d3142;">File Upload Bucket</div>
			</div>
		</td>
		<td rowspan="3" style="vertical-align: middle; width: 6%; text-align: center; padding: 0 0.2rem;">
			<div style="height: 1px; background: #eb6c36; position: relative;">
				<div style="position: absolute; right: -1px; top: -4px; width: 0; height: 0; border-left: 8px solid #eb6c36; border-top: 5px solid transparent; border-bottom: 5px solid transparent;"></div>
			</div>
		</td>
		<td rowspan="3" style="vertical-align: middle; width: 14%; padding: 0 0.4rem;">
			<div style="background: #ffffff; border: 1px solid rgba(45,49,66,0.18); border-radius: 12px; padding: 0.85rem; text-align: center;">
				<div style="display: flex; justify-content: center; margin-bottom: 0.5rem;">
					<img src="../icons/Resource-Icons_07312026/Res_Application-Integration/Res_Amazon-Simple-Notification-Service_Topic_48.svg" alt="SNS icon" style="width: 34px; height: 34px; display: block;" />
				</div>
				<div style="display: inline-block; font-family: 'Geist Mono', ui-monospace, monospace; font-size: 0.6rem; letter-spacing: 0.08em; color: #4f5d75; border: 1px solid rgba(79,93,117,0.35); border-radius: 4px; padding: 0.08rem 0.3rem; margin-bottom: 0.2rem;">SNS</div>
				<div style="font-family: 'Geist', system-ui, sans-serif; font-size: 0.85rem; font-weight: 600; color: #2d3142;">File Upload Notification</div>
			</div>
		</td>
		<td rowspan="3" style="vertical-align: middle; width: 4%; text-align: center; padding: 0;">
			<div style="height: 68%; width: 1px; background: #eb6c36; margin: 0 auto; position: relative;">
				<div style="position: absolute; top: 15%; left: -1px; width: 14px; height: 1px; background: #eb6c36;">
					<div style="position: absolute; right: -6px; top: -4px; width: 0; height: 0; border-left: 6px solid #eb6c36; border-top: 4px solid transparent; border-bottom: 4px solid transparent;"></div>
				</div>
				<div style="position: absolute; bottom: 15%; left: -1px; width: 14px; height: 1px; background: #eb6c36;">
					<div style="position: absolute; right: -6px; top: -4px; width: 0; height: 0; border-left: 6px solid #eb6c36; border-top: 4px solid transparent; border-bottom: 4px solid transparent;"></div>
				</div>
			</div>
		</td>
		<td style="vertical-align: middle; width: 13%; padding: 0 0.3rem;">
			<div style="background: #ffffff; border: 1px solid rgba(45,49,66,0.18); border-radius: 12px; padding: 0.75rem; text-align: center;">
				<div style="display: flex; justify-content: center; margin-bottom: 0.5rem;">
					<img src="../icons/Resource-Icons_07312026/Res_Application-Integration/Res_Amazon-Simple-Queue-Service_Queue_48.svg" alt="SQS icon" style="width: 30px; height: 30px; display: block;" />
				</div>
				<div style="display: inline-block; font-family: 'Geist Mono', ui-monospace, monospace; font-size: 0.58rem; letter-spacing: 0.06em; color: #4f5d75; border: 1px solid rgba(79,93,117,0.35); border-radius: 4px; padding: 0.08rem 0.3rem; margin-bottom: 0.2rem;">SQS</div>
				<div style="font-family: 'Geist', system-ui, sans-serif; font-size: 0.8rem; font-weight: 600; color: #2d3142;">Sentiments Queue</div>
			</div>
		</td>
		<td style="vertical-align: middle; width: 4%; text-align: center;">
			<div style="height: 1px; background: #eb6c36; position: relative;">
				<div style="position: absolute; right: -1px; top: -4px; width: 0; height: 0; border-left: 8px solid #eb6c36; border-top: 5px solid transparent; border-bottom: 5px solid transparent;"></div>
			</div>
		</td>
		<td style="vertical-align: middle; width: 14%; padding: 0 0.3rem;">
			<div style="background: #ffffff; border: 1px solid rgba(45,49,66,0.18); border-radius: 12px; padding: 0.75rem; text-align: center;">
				<div style="display: flex; justify-content: center; margin-bottom: 0.5rem;">
					<img src="../icons/Architecture-Service-Icons_07312026/Arch_Compute/64/Arch_AWS-Lambda_64.svg" alt="Lambda icon" style="width: 32px; height: 32px; display: block;" />
				</div>
				<div style="display: inline-block; font-family: 'Geist Mono', ui-monospace, monospace; font-size: 0.58rem; letter-spacing: 0.06em; color: #4f5d75; border: 1px solid rgba(79,93,117,0.35); border-radius: 4px; padding: 0.08rem 0.3rem; margin-bottom: 0.2rem;">LAMBDA</div>
				<div style="font-family: 'Geist', system-ui, sans-serif; font-size: 0.8rem; font-weight: 600; color: #2d3142;">Sentiment Analysis</div>
			</div>
		</td>
		<td style="vertical-align: middle; width: 4%; text-align: center;">
			<div style="height: 1px; background: #eb6c36; position: relative;">
				<div style="position: absolute; right: -1px; top: -4px; width: 0; height: 0; border-left: 8px solid #eb6c36; border-top: 5px solid transparent; border-bottom: 5px solid transparent;"></div>
			</div>
		</td>
		<td style="vertical-align: middle; width: 13%; padding: 0 0.3rem;">
			<div style="background: #ffffff; border: 1px solid rgba(45,49,66,0.18); border-radius: 12px; padding: 0.75rem; text-align: center;">
				<div style="display: flex; justify-content: center; margin-bottom: 0.5rem;">
					<img src="../icons/Architecture-Service-Icons_07312026/Arch_Databases/48/Arch_Amazon-DynamoDB_48.svg" alt="DynamoDB icon" style="width: 30px; height: 30px; display: block;" />
				</div>
				<div style="display: inline-block; font-family: 'Geist Mono', ui-monospace, monospace; font-size: 0.58rem; letter-spacing: 0.06em; color: #4f5d75; border: 1px solid rgba(79,93,117,0.35); border-radius: 4px; padding: 0.08rem 0.3rem; margin-bottom: 0.2rem;">DYNAMODB</div>
				<div style="font-family: 'Geist', system-ui, sans-serif; font-size: 0.8rem; font-weight: 600; color: #2d3142;">Sentiments Records</div>
			</div>
		</td>
	</tr>
	<tr>
		<td colspan="7" style="padding: 0.35rem 0;"></td>
	</tr>
	<tr>
		<td style="vertical-align: middle; padding: 0 0.3rem;">
			<div style="background: #ffffff; border: 1px solid rgba(45,49,66,0.18); border-radius: 12px; padding: 0.75rem; text-align: center;">
				<div style="display: flex; justify-content: center; margin-bottom: 0.5rem;">
					<img src="../icons/Resource-Icons_07312026/Res_Application-Integration/Res_Amazon-Simple-Queue-Service_Queue_48.svg" alt="SQS icon" style="width: 30px; height: 30px; display: block;" />
				</div>
				<div style="display: inline-block; font-family: 'Geist Mono', ui-monospace, monospace; font-size: 0.58rem; letter-spacing: 0.06em; color: #4f5d75; border: 1px solid rgba(79,93,117,0.35); border-radius: 4px; padding: 0.08rem 0.3rem; margin-bottom: 0.2rem;">SQS</div>
				<div style="font-family: 'Geist', system-ui, sans-serif; font-size: 0.8rem; font-weight: 600; color: #2d3142;">Conversion Queue</div>
			</div>
		</td>
		<td style="vertical-align: middle; text-align: center;">
			<div style="height: 1px; background: #eb6c36; position: relative;">
				<div style="position: absolute; right: -1px; top: -4px; width: 0; height: 0; border-left: 8px solid #eb6c36; border-top: 5px solid transparent; border-bottom: 5px solid transparent;"></div>
			</div>
		</td>
		<td style="vertical-align: middle; padding: 0 0.3rem;">
			<div style="background: #ffffff; border: 1px solid rgba(45,49,66,0.18); border-radius: 12px; padding: 0.75rem; text-align: center;">
				<div style="display: flex; justify-content: center; margin-bottom: 0.5rem;">
					<img src="../icons/Architecture-Service-Icons_07312026/Arch_Compute/64/Arch_AWS-Lambda_64.svg" alt="Lambda icon" style="width: 32px; height: 32px; display: block;" />
				</div>
				<div style="display: inline-block; font-family: 'Geist Mono', ui-monospace, monospace; font-size: 0.58rem; letter-spacing: 0.06em; color: #4f5d75; border: 1px solid rgba(79,93,117,0.35); border-radius: 4px; padding: 0.08rem 0.3rem; margin-bottom: 0.2rem;">LAMBDA</div>
				<div style="font-family: 'Geist', system-ui, sans-serif; font-size: 0.8rem; font-weight: 600; color: #2d3142;">Conversion Service</div>
			</div>
		</td>
		<td style="vertical-align: middle; text-align: center;">
			<div style="height: 1px; background: #eb6c36; position: relative;">
				<div style="position: absolute; right: -1px; top: -4px; width: 0; height: 0; border-left: 8px solid #eb6c36; border-top: 5px solid transparent; border-bottom: 5px solid transparent;"></div>
			</div>
		</td>
		<td style="vertical-align: middle; padding: 0 0.3rem;">
			<div style="background: #ffffff; border: 1px solid rgba(45,49,66,0.18); border-radius: 12px; padding: 0.75rem; text-align: center;">
				<div style="display: flex; justify-content: center; margin-bottom: 0.5rem;">
					<img src="../icons/Resource-Icons_07312026/Res_Storage/Res_Amazon-Simple-Storage-Service_Bucket_48.svg" alt="S3 icon" style="width: 30px; height: 30px; display: block;" />
				</div>
				<div style="display: inline-block; font-family: 'Geist Mono', ui-monospace, monospace; font-size: 0.58rem; letter-spacing: 0.06em; color: #4f5d75; border: 1px solid rgba(79,93,117,0.35); border-radius: 4px; padding: 0.08rem 0.3rem; margin-bottom: 0.2rem;">S3</div>
				<div style="font-family: 'Geist', system-ui, sans-serif; font-size: 0.8rem; font-weight: 600; color: #2d3142;">Converted File Storage</div>
			</div>
		</td>
	</tr>
</table>

<div style="font-family: 'Geist', system-ui, sans-serif; font-size: 0.95rem; font-weight: 600; color: #2d3142; text-align: center; margin-top: 1rem;">AWS project: an upload fans out through SNS/SQS into a Comprehend-backed sentiment lane and a markdown-to-HTML conversion lane</div>
</div>

## Test the pipeline

Upload a markdown file to trigger both lanes:

```bash
export ENDPOINT=http://localhost:4566
export UPLOAD_BUCKET=$(terraform output -raw file_upload_bucket_name)
export CONVERTED_BUCKET=$(terraform output -raw converted_file_storage_bucket_name)
export TABLE_NAME=$(terraform output -raw sentiments_table_name)

cat > note.md <<'EOF'
# Great news

This release makes our platform faster, more reliable, and delightful to use.
EOF

aws --endpoint-url "$ENDPOINT" s3 cp ./note.md "s3://$UPLOAD_BUCKET/note.md"
rm -f ./note.md
```

Check the converted HTML file and the recorded sentiment:

```bash
aws --endpoint-url "$ENDPOINT" s3 cp "s3://$CONVERTED_BUCKET/note.html" ./note.html
cat ./note.html
rm -f ./note.html

aws --endpoint-url "$ENDPOINT" dynamodb get-item \
  --table-name "$TABLE_NAME" \
  --key '{"fileKey": {"S": "note.md"}}'
```

If you want to follow the execution, watch the Floci container logs:

```bash
docker compose logs -f floci
```

## Clean up

```bash
terraform destroy
docker compose down
```
