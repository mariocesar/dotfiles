#!/usr/bin/env python3
# UserPromptSubmit hook: after a long idle the prompt cache is cold, so suggest /clear.
# Must stay 3.9-compatible; it runs under the system python3.

import json
import sys
from datetime import datetime, timezone

IDLE_MINUTES = 60


def last_reply(transcript):
    with open(transcript, "rb") as f:
        f.seek(0, 2)
        f.seek(max(0, f.tell() - 1024 * 1024))
        lines = f.read().splitlines()

    for line in reversed(lines):
        try:
            entry = json.loads(line)
        except ValueError:
            continue
        if entry.get("type") == "assistant" and entry.get("timestamp"):
            return datetime.fromisoformat(entry["timestamp"].replace("Z", "+00:00"))
    return None


def main():
    event = json.load(sys.stdin)
    try:
        since = last_reply(event["transcript_path"])
    except (KeyError, OSError):
        return
    if since is None:
        return

    idle = (datetime.now(timezone.utc) - since).total_seconds() / 60
    if idle >= IDLE_MINUTES:
        message = f"Idle {idle / 60:.1f}h, the cache is cold. Consider /clear if this is a new task."
        print(json.dumps({"systemMessage": message}))


if __name__ == "__main__":
    main()
