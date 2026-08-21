FROM nousresearch/hermes-agent:latest

USER root

# Tooling: AWS CLI for Cloudflare R2 sync, Caddy for the public proxy + basic auth.
RUN apt-get update \
    && apt-get install -y --no-install-recommends curl unzip ca-certificates gnupg \
    && rm -rf /var/lib/apt/lists/*

RUN curl -fsSL https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip -o /tmp/awscliv2.zip \
    && unzip -q /tmp/awscliv2.zip -d /tmp/aws \
    && /tmp/aws/aws/install \
    && rm -rf /tmp/awscliv2.zip /tmp/aws

RUN curl -fsSL https://github.com/caddyserver/caddy/releases/download/v2.8.4/caddy_2.8.4_linux_amd64.tar.gz -o /tmp/caddy.tgz \
    && tar -xzf /tmp/caddy.tgz -C /usr/local/bin caddy \
    && rm -f /tmp/caddy.tgz

COPY scripts/sync.sh /usr/local/bin/sync.sh
COPY scripts/gen-caddy.sh /usr/local/bin/gen-caddy.sh
COPY cont-init.d/10-hermes-render /etc/cont-init.d/10-hermes-render
RUN chmod +x /usr/local/bin/sync.sh /usr/local/bin/gen-caddy.sh /etc/cont-init.d/10-hermes-render

# Keep the base image's /init entrypoint. It receives "gateway run" and runs the
# supervised gateway + dashboard via its own s6 init. Do NOT override ENTRYPOINT.
CMD ["gateway", "run"]
