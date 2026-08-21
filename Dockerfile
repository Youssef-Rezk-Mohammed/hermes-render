FROM nousresearch/hermes-agent:latest

USER root

# Tooling: AWS CLI for Cloudflare R2 sync (curl/unzip are already in the base image)
RUN apt-get update \
    && apt-get install -y --no-install-recommends curl unzip ca-certificates gnupg \
    && rm -rf /var/lib/apt/lists/*

RUN curl -fsSL https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip -o /tmp/awscliv2.zip \
    && unzip -q /tmp/awscliv2.zip -d /tmp/aws \
    && /tmp/aws/aws/install \
    && rm -rf /tmp/awscliv2.zip /tmp/aws

COPY scripts/sync.sh /usr/local/bin/sync.sh
COPY setup.sh /usr/local/bin/setup.sh
COPY wrap.sh /usr/local/bin/wrap.sh
RUN chmod +x /usr/local/bin/sync.sh /usr/local/bin/setup.sh /usr/local/bin/wrap.sh

# The base image's s6 init (/init) supervises gateway + dashboard natively.
# wrap.sh sets env (dashboard port = $PORT) and execs /init so s6 sees it.
ENTRYPOINT ["/usr/local/bin/wrap.sh"]
CMD ["gateway", "run"]
