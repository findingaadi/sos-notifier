import json
import os
import uuid
from datetime import datetime, timezone

import boto3

table = boto3.resource("dynamodb").Table(os.environ["TABLE_NAME"])


def handler(event, context):
    try:
        data = json.loads(event.get("body") or "{}")
    except json.JSONDecodeError:
        return response(400, {"error": "Invalid JSON"})

    name = str(data.get("name", "")).strip()
    phone = str(data.get("phone", "")).strip()
    if not name or not phone:
        return response(400, {"error": "name and phone are required"})

    item = {
        "id": str(uuid.uuid4()),
        "name": name,
        "phone": phone,
        "message": str(data.get("message", "")).strip(),
        "location": str(data.get("location", "")).strip(),
        "created_at": datetime.now(timezone.utc).isoformat(),
    }
    table.put_item(Item=item)
    return response(201, {"id": item["id"]})


def response(status, body):
    return {
        "statusCode": status,
        "headers": {"Content-Type": "application/json"},
        "body": json.dumps(body),
    }