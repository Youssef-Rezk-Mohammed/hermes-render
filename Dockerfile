FROM nousresearch/hermes-agent:latest

USER root

# Tooling: AWS CLI for Cloudflare R2 sync.
RUN apt-get update \
    && apt-get install -y --no-install-recommends curl unzip ca-certificates gnupg \
    && rm -rf /var/lib/apt/lists/*

RUN curl -fsSL https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip -o /tmp/awscliv2.zip \
    && unzip -q /tmp/awscliv2.zip -d /tmp/aws \
    && /tmp/aws/aws/install \
    && rm -rf /tmp/awscliv2.zip /tmp/aws

COPY scripts/sync.sh /usr/local/bin/sync.sh
COPY cont-init.d/10-hermes-render /etc/cont-init.d/10-hermes-render
RUN chmod +x /usr/local/bin/sync.sh /etc/cont-init.d/10-hermes-render

# Back4app requires an exposed TCP port. The web dashboard stays DISABLED
# (HERMES_DASHBOARD intentionally unset): a public non-loopback dashboard bind
# requires a registered auth provider (June 2026 hardening), and the free-tier
# 256 MB RAM leaves little headroom. Instead, a static health stub serves
# $PORT (8080) so platform health checks pass.
EXPOSE 8080

# Management happens through messaging platforms (Telegram, etc.), which dial
# outbound and need no inbound ports.

CMD ["gateway", "run"]
