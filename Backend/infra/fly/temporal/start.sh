#!/bin/sh

# This is called via the fly.toml:
# [processes]
#  server = "/etc/temporal/entrypoint.sh autosetup"
#  ui = "/etc/temporal/start-ui.sh"
#
# This script itself is called in the Dockerfile:
# ENTRYPOINT ["/etc/temporal/start.sh"]
exec "$@"
