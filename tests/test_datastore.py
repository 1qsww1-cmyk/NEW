from pathlib import Path
import sys
import tempfile
import unittest

# Make project importable without installation
PROJECT_ROOT = Path(__file__).resolve().parents[1]
if str(PROJECT_ROOT) not in sys.path:
    sys.path.insert(0, str(PROJECT_ROOT))

from messenger.datastore import DataStore


class DataStoreTests(unittest.TestCase):
    def setUp(self) -> None:
        self.tmpdir = tempfile.TemporaryDirectory()
        self.store_path = Path(self.tmpdir.name) / "messages.json"
        self.store = DataStore(self.store_path)
        self.store.register_user("احمد")
        self.store.register_user("سارة")

    def tearDown(self) -> None:
        self.tmpdir.cleanup()

    def test_register_user_is_idempotent(self) -> None:
        self.store.register_user("احمد")
        payload = self.store.load()
        self.assertEqual(payload["users"].count("احمد"), 1)

    def test_send_and_inbox_outbox(self) -> None:
        message = self.store.send_message("احمد", "سارة", "أهلاً")
        self.assertIn("id", message)
        self.assertEqual(message["sender"], "احمد")
        self.assertEqual(message["recipient"], "سارة")

        inbox = self.store.get_inbox("سارة")
        outbox = self.store.get_outbox("احمد")

        self.assertEqual(len(inbox), 1)
        self.assertEqual(len(outbox), 1)
        self.assertEqual(inbox[0]["text"], "أهلاً")
        self.assertEqual(outbox[0]["id"], message["id"])

    def test_cannot_send_from_unregistered_user(self) -> None:
        with self.assertRaises(ValueError):
            self.store.send_message("مجهول", "سارة", "مرحبا")

    def test_cannot_send_to_unregistered_user(self) -> None:
        with self.assertRaises(ValueError):
            self.store.send_message("احمد", "غير_موجود", "مرحبا")


if __name__ == "__main__":
    unittest.main()
