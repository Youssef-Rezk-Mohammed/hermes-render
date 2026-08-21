#!/bin/bash
# Sync Hermes state (/opt/data) with a Cloudflare R2 bucket (S3-compatible).
# Required env: R2_ENDPOINT, AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, R2_BUCKET
set -e || true
ACTION="${1:-up}"
BUCKET="${R2_BUCKET:-hermes-data}"
PREFIX="${R2_PREFIX:-data}"

if [ -z "$R2_ENDPOINT" ] || [ -z "$AWS_ACCESS_KEY_ID" ] || [ -z "$AWS_SECRET_ACCESS_KEY" ]; then
  echo "[sync] R2 not configured; skipping."
  exit 0
fi

export AWS_ENDPOINT_URL="$R2_ENDPOINT"
export AWS_DEFAULT_REGION="auto"
export AWS_ACCESS_KEY_ID="$AWS_ACCESS_KEY_ID"
export AWS_SECRET_ACCESS_KEY="$AWS_SECRET_ACCESS_KEY"

case "$ACTION" in
  up)   echo "[sync] pushing /opt/data -> s3://$BUCKET/$PREFIX"; aws s3 sync /opt/data "s3://$BUCKET/$PREFIX" --delete ;;
  down) echo "[sync] restoring s3://$BUCKET/$PREFIX -> /opt/data"; aws s3 sync "s3://$BUCKET/$PREFIX" /opt/data --delete ;;
  *) echo "usage: sync.sh up|down"; exit 1 ;;
esac
