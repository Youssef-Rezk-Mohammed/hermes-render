#!/usr/bin/env bash
set -e || true
PORT="${PORT:-8080}"
DASH_USER="${DASHBOARD_USER:-admin}"
DASH_PASS="${DASHBOARD_PASSWORD:-changeme}"
mkdir -p /etc/caddy
HASH=$(caddy hash-password "$DASH_PASS")
cat > /etc/caddy/Caddyfile <<EOF
{
    admin off
}
:${PORT} {
    basicauth {
        ${DASH_USER} ${HASH}
    }
    reverse_proxy 127.0.0.1:9119
}
EOF
echo "wrote /etc/caddy/Caddyfile for port ${PORT}"
