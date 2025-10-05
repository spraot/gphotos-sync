FROM golang:trixie AS build

ENV DEFAULT_GPHOTOS_CDP_VERSION=github.com/spraot/gphotos-cdp@2fe62df6
ENV GO111MODULE=on

ARG GPHOTOS_CDP_VERSION=$DEFAULT_GPHOTOS_CDP_VERSION

# temporary workaround to disable chrome sandbox when instantiating chrome
# RUN go install $GPHOTOS_CDP_VERSION
RUN git clone https://github.com/spraot/gphotos-cdp.git &&\
    sed -i '/chromedp\.Flag("enable-logging", true)/a \\t\tchromedp.Flag("no-sandbox", true),' gphotos-cdp/main.go
WORKDIR /go/gphotos-cdp
RUN go install ./...

FROM debian:trixie-slim

ENV \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    CRON_SCHEDULE="0 0 * * *" \
    RESTART_SCHEDULE= \
    DEBIAN_FRONTEND=noninteractive \
    LOGLEVEL=INFO \
    HEALTHCHECK_HOST="https://hc-ping.com" \
    HEALTHCHECK_ID= \
    ALBUMS= \
    WORKER_COUNT=6 \
    GPHOTOS_CDP_ARGS=

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        apt-transport-https \
        ca-certificates \
        curl \
        cron \
        exiftool \
        jq \
        wget \
        sudo && \
    rm -rf /var/lib/apt/lists/*

# install latest chrome
COPY src/install_chrome.sh .
RUN ./install_chrome.sh

COPY --from=build /go/bin/gphotos-cdp /usr/bin/
COPY src ./app/
RUN chmod +x /app/*.sh

USER root
ENTRYPOINT ["/app/start.sh"]
CMD [""]
