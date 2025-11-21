from __future__ import annotations

import json
from dataclasses import dataclass
from datetime import datetime
from pathlib import Path
from typing import Dict, List
from uuid import uuid4


Message = Dict[str, str]


@dataclass
class DataStore:
    """Simple JSON-based store for users and messages."""

    path: Path

    def __post_init__(self) -> None:
        self.path = Path(self.path)
        self.path.parent.mkdir(parents=True, exist_ok=True)

    def _initial_payload(self) -> Dict[str, List]:
        return {"users": [], "messages": []}

    def load(self) -> Dict[str, List]:
        if not self.path.exists():
            return self._initial_payload()
        with self.path.open("r", encoding="utf-8") as fp:
            return json.load(fp)

    def save(self, payload: Dict[str, List]) -> None:
        with self.path.open("w", encoding="utf-8") as fp:
            json.dump(payload, fp, ensure_ascii=False, indent=2)

    def register_user(self, username: str) -> None:
        payload = self.load()
        if username not in payload["users"]:
            payload["users"].append(username)
            self.save(payload)

    def _ensure_user_exists(self, payload: Dict[str, List], username: str) -> None:
        if username not in payload["users"]:
            raise ValueError(f"المستخدم '{username}' غير مسجل")

    def send_message(self, sender: str, recipient: str, text: str) -> Message:
        payload = self.load()
        self._ensure_user_exists(payload, sender)
        self._ensure_user_exists(payload, recipient)

        message = {
            "id": str(uuid4()),
            "sender": sender,
            "recipient": recipient,
            "text": text,
            "sent_at": datetime.utcnow().isoformat() + "Z",
        }
        payload["messages"].append(message)
        self.save(payload)
        return message

    def get_inbox(self, username: str) -> List[Message]:
        payload = self.load()
        self._ensure_user_exists(payload, username)
        return [msg for msg in payload["messages"] if msg["recipient"] == username]

    def get_outbox(self, username: str) -> List[Message]:
        payload = self.load()
        self._ensure_user_exists(payload, username)
        return [msg for msg in payload["messages"] if msg["sender"] == username]
