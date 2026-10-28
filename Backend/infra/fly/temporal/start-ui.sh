#!/bin/sh

# The Temporal UI Server expects the script to be executed at the `/home/ui-server`
cd /home/ui-server
# Assuming your server/ui is running in the same Fly app (but different process)
# Change this to another fly app or IP if running elsewhere.
export TEMPORAL_ADDRESS="${FLY_APP_NAME}.flycast:7233"
export TEMPORAL_CSRF_COOKIE_INSECURE=true
./start-ui-server.sh
