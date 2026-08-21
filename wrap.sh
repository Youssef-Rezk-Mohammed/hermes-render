#!/bin/bash
set -e
# Render injects $PORT; the dashboard must listen on it for the public URL + health check.
export HERMES_DASHBOARD_PORT="${PORT:-8080}"
# Restore from R2, seed the OpenCode Zen config, start the sync loop, then hand off to s6.
/usr/local/bin/setup.sh
exec /init "$@"
