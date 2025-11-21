from __future__ import annotations

import argparse
from pathlib import Path
from typing import List

from messenger.datastore import DataStore

DEFAULT_PATH = Path("data/messages.json")

def format_messages(messages: List[dict]) -> str:
    if not messages:
        return "لا توجد رسائل."

    lines = []
    for msg in messages:
        lines.append(
            f"- ({msg['sent_at']}) من {msg['sender']} إلى {msg['recipient']}: {msg['text']}"
        )
    return "\n".join(lines)

def main() -> None:
    parser = argparse.ArgumentParser(description="تطبيق بسيط لإرسال الرسائل.")
    parser.add_argument(
        "--store",
        type=Path,
        default=DEFAULT_PATH,
        help="مكان حفظ البيانات (افتراضي: data/messages.json)",
    )

    subparsers = parser.add_subparsers(dest="command", required=True)

    user_parser = subparsers.add_parser("register", help="تسجيل مستخدم جديد")
    user_parser.add_argument("username", help="اسم المستخدم")

    send_parser = subparsers.add_parser("send", help="إرسال رسالة")
    send_parser.add_argument("sender", help="اسم المرسل")
    send_parser.add_argument("recipient", help="اسم المستلم")
    send_parser.add_argument("text", help="نص الرسالة")

    inbox_parser = subparsers.add_parser("inbox", help="عرض الوارد")
    inbox_parser.add_argument("username", help="اسم المستخدم")

    sent_parser = subparsers.add_parser("sent", help="عرض الصادر")
    sent_parser.add_argument("username", help="اسم المستخدم")

    args = parser.parse_args()
    store = DataStore(args.store)

    if args.command == "register":
        store.register_user(args.username)
        print(f"تم تسجيل {args.username} بنجاح.")
    elif args.command == "send":
        message = store.send_message(args.sender, args.recipient, args.text)
        print(f"تم إرسال الرسالة برقم {message['id']}.")
    elif args.command == "inbox":
        inbox = store.get_inbox(args.username)
        print(format_messages(inbox))
    elif args.command == "sent":
        outbox = store.get_outbox(args.username)
        print(format_messages(outbox))


if __name__ == "__main__":
    main()
