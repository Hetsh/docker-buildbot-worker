FROM amd64/alpine:20230208
RUN apk update && \
    # Buildbot-Worker dependencies
    apk add --no-cache \
        python3=3.11.2-r0 \
        py3-autobahn=22.12.1-r0 \
        py3-txaio=23.1.1-r0 \
        py3-zope-interface=5.5.2-r0 \
        py3-msgpack=1.0.4-r1 \
        py3-twisted=22.10.0-r1 \
        py3-setuptools=67.3.2-r0 \
        py3-hyperlink=21.0.0-r3 \
        py3-cryptography=39.0.1-r0 \
        py3-typing-extensions=4.5.0-r0 \
        py3-attrs=22.2.0-r0 \
        py3-automat=22.10.0-r1 \
        py3-incremental=22.10.0-r1 \
        py3-constantly=15.1.0-r6 \
        py3-idna=3.4-r3 \
        py3-cffi=1.15.1-r1 && \
    # Custom dependencies for updating Docker images
    apk add --no-cache \
        jq=1.6-r2 \
        git=2.39.2-r0 \
        curl=7.88.1-r0 \
        grep=3.8-r1 \
        bash=5.2.15-r0 \
        coreutils=9.1-r0 \
        docker-cli=23.0.1-r1 \
        openssh-client-default=9.2_p1-r0

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
