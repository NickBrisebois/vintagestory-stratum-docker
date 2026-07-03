FROM debian:12-slim AS setup

ENV STRATUM_RELEASE="14"
ENV STRATUM_RELEASE_SHA256="sha256:35e981eaaf4dee68fa78352503945b0b1bf1757956099f0f15576974a521ee81" \
    STRATUM_RELEASE_URI="https://github.com/StratumServer/Stratum/releases/download/v1.22.3-stratum.${STRATUM_RELEASE}/stratum-1.22.3-stratum.${STRATUM_RELEASE}-linux-x64.zip"

RUN set -eux; \
    apt-get update; \
    apt-get install --no-install-recommends -y wget unzip ca-certificates; \
    rm -rf /var/lib/apt/lists/*; \
    mkdir /data

WORKDIR /data

RUN set -eux; \
    wget -q -O /tmp/stratum_server.zip \
        "${STRATUM_RELEASE_URI}"; \
    test "$STRATUM_RELEASE_SHA256" = "sha256:$(sha256sum /tmp/stratum_server.zip | cut -d' ' -f1)"; \
    unzip -q /tmp/stratum_server.zip -d /data; \
    rm -f /tmp/stratum_server.zip

FROM mcr.microsoft.com/dotnet/runtime:10.0

RUN set -eux; \
    apt-get update; \
    apt-get install --no-install-recommends -y \
        screen wget ca-certificates netcat-traditional jq moreutils passwd util-linux; \
    apt-get clean; \
    rm -rf /var/lib/apt/lists/*

RUN set -eux; \
    if getent passwd ubuntu >/dev/null; then userdel --remove ubuntu; fi; \
    if getent group ubuntu >/dev/null; then groupdel ubuntu; fi; \
    groupadd vintagestory; \
    useradd --gid vintagestory --shell /bin/false -M vintagestory

COPY --from=setup /data /data
RUN chown -R vintagestory:vintagestory /data

ENV SERVER_PORT=42420 \
    SERVER_VERSION="1.22.3" \
    SERVER_BRANCH="stable"

EXPOSE 42420
HEALTHCHECK --start-period=1m --interval=5s CMD nc -z 127.0.0.1 "$SERVER_PORT"
VOLUME ["/data/vintage"]

COPY serverconfig.json /data/default-serverconfig.json
COPY entry.sh /data/scripts/entry.sh
CMD ["sh", "/data/scripts/entry.sh"]
