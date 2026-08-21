#!/usr/bin/env bash
# Generate /etc/caddy/Caddyfile: public $PORT proxy (basic auth) -> loopback dashboard.
set -e || true
export HOME=/root
PORT="${PORT:-8080}"
DASH_USER="${DASHBOARD_USER:-admin}"
# Fall back to "changeme" so Caddy can ALWAYS build a valid hash (deploy goes green
# even before the user sets a real password; they should override DASHBOARD_PASSWORD).
DASH_PASS="${DASHBOARD_PASSWORD:-changeme}"
mkdir -p /etc/caddy
HASH="$(caddy hash-password "$DASH_PASS" 2>/dev/null)"
if [ -z "$HASH" ]; then
  echo "[gen-caddy] WARNING: hash-password returned empty; basic auth may be broken." >&2
fi
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
echo "wrote /etc/caddy/Caddyfile (port ${PORT}, user ${DASH_USER})"
