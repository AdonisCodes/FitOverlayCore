#!/bin/sh
set -eu

python3 /pgadmin4/bootstrap-pgadmin.py
exec /entrypoint.sh
