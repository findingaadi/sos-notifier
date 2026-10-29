import json
import os
import re
import uuid
from datetime import datetime, timezone
from decimal import Decimal, InvalidOperation

import boto3

table = boto3.resource("dynamodb").Table(os.environ["TABLE_NAME"])


def handler(event, context):
    try:
        data = json.loads(event.get("body") or "{}")
        location = data.get("location") or {}
        lat = Decimal(str(location.get("lat")))
        lon = Decimal(str(location.get("lon")))
        radius = Decimal(str(data.get("radius")))
        valid_numbers = -90 <= lat <= 90 and -180 <= lon <= 180 and 0 < radius <= 1000
    except (json.JSONDecodeError, InvalidOperation, AttributeError):
        return response(400, {"error": "invalid input"})

    name = str(data.get("name", "")).strip()
    number = str(data.get("number", "")).strip()
    # Twilio dials this number, so only accept international format like +447700900123
    if not name or not re.fullmatch(r"\+\d{8,15}", number) or not valid_numbers:
        return response(400, {"error": "invalid input"})

    item = {
        "id": str(uuid.uuid4()),
        "name": name,
        "email": str(data.get("email", "")).strip(),
        "number": number,
        "radius": radius,
        "location": {"lat": lat, "lon": lon},
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