
import sqlite3
from pathlib import Path

database_path = (
    Path(__file__).resolve().parent
    / "colmap_workspace"
    / "database.db"
)

if not database_path.exists():
    print("LOI: Khong tim thay database.db")
    raise SystemExit(1)

print("Database:", database_path)
print("Size:", database_path.stat().st_size, "bytes")

connection = sqlite3.connect(str(database_path))

try:
    cursor = connection.execute(
        "SELECT name FROM sqlite_master WHERE type = 'table'"
    )

    tables = cursor.fetchall()

    print("Tables:", tables)
finally:
    connection.close()
