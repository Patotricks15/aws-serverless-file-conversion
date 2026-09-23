"""conversion_service: converts an uploaded markdown file to HTML and stores the result in the destination bucket."""
import json
import os
import urllib.parse

import boto3
import markdown

DEST_BUCKET = os.environ["DEST_BUCKET"]
REGION = os.environ.get("REGION", "us-east-1")
ENDPOINT_URL = "http://localhost:4566"

s3 = boto3.client(
    "s3",
    region_name=REGION,
    endpoint_url=ENDPOINT_URL,
    aws_access_key_id="test",
    aws_secret_access_key="test",
)

HTML_TEMPLATE = """<!DOCTYPE html>
<html lang="en">
<head><meta charset="utf-8"><title>{title}</title></head>
<body>
{body}
</body>
</html>
"""


def lambda_handler(event, context):
    converted = []

    for record in event.get("Records", []):
        s3_event = json.loads(record["body"])

        for s3_record in s3_event.get("Records", []):
            bucket = s3_record["s3"]["bucket"]["name"]
            key = urllib.parse.unquote_plus(s3_record["s3"]["object"]["key"])

            obj = s3.get_object(Bucket=bucket, Key=key)
            markdown_text = obj["Body"].read().decode("utf-8")

            body_html = markdown.markdown(markdown_text, extensions=["fenced_code", "tables"])
            dest_key = key.rsplit(".", 1)[0] + ".html"
            document = HTML_TEMPLATE.format(title=dest_key, body=body_html)

            s3.put_object(
                Bucket=DEST_BUCKET,
                Key=dest_key,
                Body=document.encode("utf-8"),
                ContentType="text/html",
            )
            converted.append(dest_key)

    return {"converted": converted}
