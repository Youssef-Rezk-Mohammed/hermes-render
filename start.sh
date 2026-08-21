#!/bin/bash
set -e

PORT="${PORT:-8080}"
DASH_PORT=9119
DASH_USER="${DASHBOARD_USER:-admin}"
DASH_PASS="${DASHBOARD_PASSWORD:-changeme}"

# Render injects $PORT; the public web service must listen on it.
# Caddy sits in front of the dashboard with HTTP basic auth (required on a public bind).
HASH=$(caddy hash-password "$DASH_PASS")
cat > /etc/caddy/Caddyfile <<EOF
{
    admin off
}
:${PORT} {
    basicauth {
        ${DASH_USER} ${HASH}
    }
    reverse_proxy 127.0.0.1:${DASH_PORT}
}
EOF

# Restore persistent state from R2 on cold start (best-effort).
/usr/local/bin/sync.sh down || true

exec supervisord -c /etc/supervisor/conf.d/supervisord.conf
