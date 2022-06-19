FROM amd64/alpine:20220328
RUN apk update && \
    # Buildbot-Worker dependencies
    apk add --no-cache \
        python3=3.10.5-r0 \
        pythonispython3=3.10.5-r0 \
        py3-autobahn=21.3.1-r2 \
        py3-txaio=21.2.1-r2 \
        py3-zope-interface=5.4.0-r1 \
        py3-msgpack=1.0.4-r0 \
        py3-twisted=22.2.0-r0 \
        py3-setuptools=59.4.0-r0 \
        py3-hyperlink=21.0.0-r2 \
        py3-cryptography=3.4.8-r1 \
        py3-typing-extensions=4.2.0-r0 \
        py3-attrs=21.4.0-r0 \
        py3-automat=20.2.0-r2 \
        py3-incremental=21.3.0-r2 \
        py3-constantly=15.1.0-r5 \
        py3-idna=3.3-r2 \
        py3-cffi=1.15.0-r0 && \
    # Custom dependencies for updating Docker images
    apk add --no-cache \
        jq=1.6-r1 \
        git=2.36.1-r0 \
        curl=7.83.1-r1 \
        grep=3.7-r0 \
        bash=5.1.16-r2 \
        openssh-client-default=9.0_p1-r1

# App user
ARG APP_USER="buildbot"
ARG APP_UID=1381
ARG DATA_DIR="/buildbot"
RUN adduser \
    --disabled-password \
    --uid "$APP_UID" \
    --home "$DATA_DIR" \
    --gecos "$APP_USER" \
    --shell /sbin/nologin \
    "$APP_USER"
VOLUME ["$DATA_DIR"]

# Server files
ARG APP_VERSION=3.5.0
RUN WORKER_ARCHIVE="worker.tar.gz" && \
    wget \
        --quiet \
        --output-document \
        "$WORKER_ARCHIVE" \
        "https://github.com/buildbot/buildbot/releases/download/v$APP_VERSION/buildbot-worker-$APP_VERSION.tar.gz" && \
    tar --extract --file="$WORKER_ARCHIVE" && \
    rm "$WORKER_ARCHIVE" && \
    WORKER_DIRECTORY="buildbot-worker-$APP_VERSION" && \
    cd "$WORKER_DIRECTORY" && \
    python setup.py build && \
    python setup.py install && \
    cd .. && \
    rm -r "$WORKER_DIRECTORY"

USER "$APP_USER"
WORKDIR "$DATA_DIR"
ENTRYPOINT ["buildbot-worker"]
CMD ["start", "--nodaemon"]
