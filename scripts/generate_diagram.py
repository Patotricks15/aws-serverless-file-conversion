"""Generates docs/architecture.drawio for the Serverless File Conversion project using drawpyo.

Run with: python3 scripts/generate_diagram.py
"""
import os

import drawpyo

OUTPUT_DIR = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "docs")

AWS4_BASE = (
    "sketch=0;outlineConnect=0;fontColor=#232F3E;gradientColor=none;strokeColor=none;"
    "dashed=0;verticalLabelPosition=bottom;verticalAlign=top;align=center;html=1;"
    "fontSize=11;fontStyle=0;aspect=fixed;pointerEvents=1;"
)


def aws_style(icon_name, fill_color):
    return f"{AWS4_BASE}fillColor={fill_color};shape=mxgraph.aws4.resourceIcon;resIcon=mxgraph.aws4.{icon_name};"


def add_node(page, name, x, y, icon_name, fill_color, width=64, height=64):
    node = drawpyo.diagram.Object(page=page, value=name)
    node.position = (x, y)
    node.geometry.width = width
    node.geometry.height = height
    node.apply_style_string(aws_style(icon_name, fill_color))
    return node


def add_edge(page, source, target, label=None):
    edge = drawpyo.diagram.Edge(page=page, source=source, target=target, label=label)
    edge.waypoints = "orthogonal"
    edge.endArrow = "block"
    edge.startArrow = "none"
    edge.strokeColor = "#545B64"
    return edge


def build_diagram():
    file = drawpyo.File()
    file.file_name = "architecture.drawio"
    file.file_path = OUTPUT_DIR

    page = drawpyo.Page(file=file)
    page.name = "Serverless File Conversion"

    upload_bucket = add_node(page, "File Upload\nBucket (S3)", 40, 120, "bucket", "#7AA116")
    sns_topic = add_node(page, "File Upload\nNotification (SNS)", 200, 120, "sns", "#E7157B")

    sentiments_queue = add_node(page, "Sentiments\nQueue (SQS)", 360, 40, "sqs", "#E7157B")
    sentiment_lambda = add_node(page, "Sentiment Analysis\n(Lambda)", 520, 40, "lambda_function", "#ED7100")
    comprehend = add_node(page, "Comprehend", 520, -60, "comprehend", "#01A88D")
    sentiments_table = add_node(page, "Sentiments Records\n(DynamoDB)", 680, 40, "dynamodb", "#C925D1", height=80)

    conversion_queue = add_node(page, "Conversion\nQueue (SQS)", 360, 220, "sqs", "#E7157B")
    conversion_lambda = add_node(page, "Conversion Service\n(Lambda)", 520, 220, "lambda_function", "#ED7100")
    converted_bucket = add_node(page, "Converted File\nStorage (S3)", 680, 220, "bucket", "#7AA116")

    add_edge(page, upload_bucket, sns_topic)
    add_edge(page, sns_topic, sentiments_queue)
    add_edge(page, sns_topic, conversion_queue)

    add_edge(page, sentiments_queue, sentiment_lambda)
    add_edge(page, sentiment_lambda, comprehend, "detect_sentiment")
    add_edge(page, sentiment_lambda, sentiments_table, "put_item")

    add_edge(page, conversion_queue, conversion_lambda)
    add_edge(page, conversion_lambda, converted_bucket, "markdown to HTML")

    os.makedirs(OUTPUT_DIR, exist_ok=True)
    file.write()
    print(f"Wrote {os.path.join(OUTPUT_DIR, file.file_name)}")


if __name__ == "__main__":
    build_diagram()
