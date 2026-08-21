FROM nousresearch/hermes-agent:latest

USER root

# supervisor (process manager) + tooling
RUN apt-get update \
    && apt-get install -y --no-install-recommends supervisor curl unzip ca-certificates gnupg \
    && rm -rf /var/lib/apt/lists/*

# Caddy (reverse proxy + basic auth in front of the dashboard)
RUN curl -fsSL https://github.com/caddyserver/caddy/releases/download/v2.8.4/caddy_2.8.4_linux_amd64.tar.gz -o /tmp/caddy.tgz \
    && tar -xzf /tmp/caddy.tgz -C /usr/local/bin caddy \
    && rm -f /tmp/caddy.tgz

# AWS CLI v2 (for Cloudflare R2 sync via S3-compatible API)
RUN curl -fsSL https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip -o /tmp/awscliv2.zip \
    && unzip -q /tmp/awscliv2.zip -d /tmp/aws \
    && /tmp/aws/aws/install \
    && rm -rf /tmp/awscliv2.zip /tmp/aws

# App files
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY Caddyfile /etc/caddy/Caddyfile.tmpl
COPY start.sh /usr/local/bin/start.sh
COPY scripts/sync.sh /usr/local/bin/sync.sh
RUN chmod +x /usr/local/bin/start.sh /usr/local/bin/sync.sh

EXPOSE 8080

# Supervisord runs as root so it can start all child processes.
CMD ["/usr/local/bin/start.sh"]
