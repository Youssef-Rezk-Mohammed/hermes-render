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

# Seed Hermes config with the OpenCode Zen provider if not already present.
# /opt/data is the Hermes home and is synced to R2, so this persists across redeploys.
# OPENCODE_API_KEY  -> your OpenCode Zen key (required)
# OPENCODE_BASE_URL -> default https://opencode.ai/zen/v1
# OPENCODE_MODEL    -> any Zen chat model, e.g. deepseek-v4-flash
CFG=/opt/data/config.yaml
if [ ! -f "$CFG" ]; then
  mkdir -p /opt/data
  cat > "$CFG" <<EOF
model:
  provider: custom
  default: ${OPENCODE_MODEL:-deepseek-v4-flash}
  base_url: ${OPENCODE_BASE_URL:-https://opencode.ai/zen/v1}
  api_key: ${OPENCODE_API_KEY:-}
EOF
fi

exec supervisord -c /etc/supervisor/conf.d/supervisord.conf
