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

# Keep the base image's /init entrypoint. It receives "gateway run" and runs the
# supervised gateway + dashboard via its own s6 init. Do NOT override ENTRYPOINT.
CMD ["gateway", "run"]
