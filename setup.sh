#!/bin/bash
set -e
CFG=/opt/data/config.yaml

# 1. Restore persistent state from R2 (best-effort; skips if R2 not configured).
/usr/local/bin/sync.sh down || true

# 2. Seed Hermes config with the OpenCode Zen provider if not already present.
mkdir -p /opt/data
if [ ! -f "$CFG" ]; then
  cat > "$CFG" <<EOF
model:
  provider: custom
  default: ${OPENCODE_MODEL:-deepseek-v4-flash}
  base_url: ${OPENCODE_BASE_URL:-https://opencode.ai/zen/v1}
  api_key: ${OPENCODE_API_KEY:-}
EOF
fi

# 3. Background R2 sync loop (every 5 min) so redeploys don't wipe memory/sessions/skills.
( while true; do sleep 300; /usr/local/bin/sync.sh up || true; done ) &
