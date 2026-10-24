import json
import os
import sys
from pathlib import Path
from urllib.parse import unquote, urlparse


def load_primary_postgres_url() -> str:
    env_file = os.environ.get("POSTGRES_ENV_FILE")
    if env_file:
        for line in Path(env_file).read_text().splitlines():
            stripped = line.strip()
            if not stripped or stripped.startswith("#") or "=" not in stripped:
                continue
            key, value = stripped.split("=", 1)
            if key.strip() != "PRIMARY_POSTGRES_URL":
                continue
            return value.strip().strip('"').strip("'")

    postgres_url = os.environ.get("PRIMARY_POSTGRES_URL")
    if postgres_url:
        return postgres_url

    raise ValueError("PRIMARY_POSTGRES_URL was not found in POSTGRES_ENV_FILE or env")


def parse_postgres_url(raw_url: str) -> dict[str, str]:
    parsed = urlparse(raw_url)
    if parsed.scheme not in {"postgres", "postgresql"}:
        raise ValueError(
            f"Unsupported PRIMARY_POSTGRES_URL scheme: {parsed.scheme or '<missing>'}"
        )
    if not parsed.hostname:
        raise ValueError("PRIMARY_POSTGRES_URL is missing a hostname")
    if not parsed.username:
        raise ValueError("PRIMARY_POSTGRES_URL is missing a username")

    database = parsed.path.lstrip("/") or "postgres"
    return {
        "Name": os.environ.get("PGADMIN_SERVER_NAME", "Local Postgres"),
        "Group": "Servers",
        "Host": parsed.hostname,
        "Port": parsed.port or 5432,
        "MaintenanceDB": database,
        "Username": unquote(parsed.username),
        "Password": unquote(parsed.password or ""),
        "SSLMode": "prefer",
    }


def main() -> int:
    try:
        postgres_url = load_primary_postgres_url()
    except ValueError as exc:
        print(str(exc), file=sys.stderr)
        return 1

    server = parse_postgres_url(postgres_url)
    servers_path = Path("/var/lib/pgadmin/servers.json")
    servers_path.parent.mkdir(parents=True, exist_ok=True)
    servers_path.write_text(json.dumps({"Servers": {"1": server}}, indent=2) + "\n")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
