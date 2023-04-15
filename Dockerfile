FROM amd64/alpine:20230329
RUN apk update && \
    # Buildbot-Worker dependencies
    apk add --no-cache \
        python3=3.11.3-r4 \
        py3-autobahn=22.12.1-r0 \
        py3-txaio=23.1.1-r0 \
        py3-zope-interface=5.5.2-r0 \
        py3-msgpack=1.0.5-r0 \
        py3-twisted=22.10.0-r2 \
        py3-setuptools=67.6.1-r0 \
        py3-hyperlink=21.0.0-r3 \
        py3-cryptography=40.0.1-r0 \
        py3-typing-extensions=4.5.0-r0 \
        py3-attrs=22.2.0-r0 \
        py3-automat=22.10.0-r1 \
        py3-incremental=22.10.0-r1 \
        py3-constantly=15.1.0-r6 \
        py3-idna=3.4-r3 \
        py3-cffi=1.15.1-r2 && \
    # Custom dependencies for updating Docker images
    apk add --no-cache \
        jq=1.6-r3 \
        git=2.40.0-r1 \
        curl=8.0.1-r2 \
        grep=3.10-r1 \
        bash=5.2.15-r3 \
        coreutils=9.2-r3 \
        docker-cli=23.0.3-r2 \
        openssh-client-default=9.3_p1-r2

# App user
ARG APP_USER="buildbot"
ARG APP_UID=1381
ARG DATA_DIR="/buildbot"
ARG DOCKER_GROUP="docker"
RUN addgroup \
        --gid "972" \
        "$DOCKER_GROUP" && \
    adduser \
        --disabled-password \
        --uid "$APP_UID" \
        --home "$DATA_DIR" \
        --gecos "$APP_USER" \
        --shell /sbin/nologin \
        --ingroup "$DOCKER_GROUP" \
        "$APP_USER"
VOLUME ["$DATA_DIR"]

# Server files
ARG APP_VERSION=3.7.0
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
