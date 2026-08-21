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

# Back4app requires the Dockerfile to EXPOSE a port (its launch validator rejects
# images that don't). The dashboard binds $PORT at runtime; 8080 matches the
# Back4app "Port" setting. EXPOSE is documentation/manifest only.
EXPOSE 8080

# Dashboard runtime config baked as ENV so s6-overlay reliably propagates it to
# the supervised dashboard service. Port-injection via cont-init file writes was
# fragile and left the dashboard on its default loopback :9119 (nothing on 8080).
# Port 8080 matches the Back4app "Port" setting. DASHBOARD_PASSWORD / OPENCODE_*
# stay as Back4app runtime env vars (secrets must not be baked into the image).
ENV HERMES_DASHBOARD=1 \
    HERMES_DASHBOARD_HOST=0.0.0.0 \
    HERMES_DASHBOARD_PORT=8080

# Keep the base image's /init entrypoint. It receives "gateway run" and runs the
# supervised gateway + dashboard via its own s6 init. Do NOT override ENTRYPOINT.
CMD ["gateway", "run"]
