"""sentiment_analysis: reads an uploaded markdown file, runs Comprehend sentiment analysis, and stores the result in DynamoDB."""
import json
import os
import urllib.parse
from datetime import datetime, timezone

import boto3

TABLE_NAME = os.environ["TABLE_NAME"]
REGION = os.environ.get("REGION", "us-east-1")
ENDPOINT_URL = "http://localhost:4566"

session_kwargs = {
    "region_name": REGION,
    "endpoint_url": ENDPOINT_URL,
    "aws_access_key_id": "test",
    "aws_secret_access_key": "test",
}

s3 = boto3.client("s3", **session_kwargs)
comprehend = boto3.client("comprehend", **session_kwargs)
dynamodb = boto3.resource("dynamodb", **session_kwargs)
table = dynamodb.Table(TABLE_NAME)

# Comprehend's synchronous sentiment API accepts at most 5000 UTF-8 bytes per call.
MAX_TEXT_BYTES = 5000


def lambda_handler(event, context):
    processed = []

    for record in event.get("Records", []):
        s3_event = json.loads(record["body"])

        for s3_record in s3_event.get("Records", []):
            bucket = s3_record["s3"]["bucket"]["name"]
            key = urllib.parse.unquote_plus(s3_record["s3"]["object"]["key"])

            obj = s3.get_object(Bucket=bucket, Key=key)
            markdown_text = obj["Body"].read().decode("utf-8")

            sentiment = comprehend.detect_sentiment(
                Text=markdown_text.encode("utf-8")[:MAX_TEXT_BYTES].decode("utf-8", "ignore"),
                LanguageCode="en",
            )

            table.put_item(
                Item={
                    "fileKey": key,
                    "sentiment": sentiment["Sentiment"],
                    "sentimentScore": {
                        label: str(score) for label, score in sentiment["SentimentScore"].items()
                    },
                    "analyzedAt": datetime.now(timezone.utc).isoformat(),
                }
            )
            processed.append(key)

    return {"processed": processed}
