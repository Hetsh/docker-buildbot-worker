FROM amd64/alpine:20220328
RUN apk update && \
    apk add --no-cache \
        python3=3.10.4-r0 \
        pythonispython3=3.10.4-r0 \
        py3-greenlet=1.1.2-r2 \
        py3-yaml=6.0-r0 \
        py3-jwt=2.4.0-r0 \
        py3-autobahn=21.3.1-r2 \
        py3-txaio=21.2.1-r2 \
        py3-dateutil=2.8.2-r1 \
        py3-alembic=1.7.7-r0 \
        py3-sqlalchemy=1.4.36-r0 \
        py3-zope-interface=5.4.0-r1 \
        py3-msgpack=1.0.3-r0 \
        py3-jinja2=3.0.3-r1 \
        py3-twisted=22.2.0-r0 \
        py3-setuptools=59.4.0-r0 \
        py3-hyperlink=21.0.0-r2 \
        py3-cryptography=3.4.8-r1 \
        py3-six=1.16.0-r1 \
        py3-mako=1.2.0-r0 \
        py3-markupsafe=2.1.1-r0 \
        py3-typing-extensions=4.2.0-r0 \
        py3-attrs=21.4.0-r0 \
        py3-automat=20.2.0-r2 \
        py3-incremental=21.3.0-r2 \
        py3-constantly=15.1.0-r5 \
        py3-idna=3.3-r2 \
        py3-cffi=1.15.0-r0 \
        py3-cparser=2.20-r2

# App user
ARG APP_USER="buildbot"
ARG APP_UID=1381
RUN adduser \
    --disabled-password \
    --uid "$APP_UID" \
    --no-create-home \
    --gecos "$APP_USER" \
    --shell /sbin/nologin \
    "$APP_USER"

# Server files
ARG APP_VERSION="3.5.0"
RUN WORKER_ARCHIVE="worker.tar.gz" && \
    wget \
        --quiet \
        --output-document \
        "$WORKER_ARCHIVE" \
        "https://github.com/buildbot/buildbot/releases/download/v$APP_VERSION/buildbot-$APP_VERSION.tar.gz" && \
    tar --extract --file="$WORKER_ARCHIVE" && \
    rm "$WORKER_ARCHIVE" && \
    BB_DIRECTORY="buildbot-$APP_VERSION" && \
    cd "$BB_DIRECTORY" && \
    python setup.py build && \
    python setup.py install && \
    cd .. && \
    rm -r "$BB_DIRECTORY"

# Volumes
ARG BASE_DIR="/buildbot"
RUN mkdir "$BASE_DIR" && \
    chown "$APP_USER":"$APP_USER" "$BASE_DIR"
VOLUME ["$BASE_DIR"]

USER "$APP_USER"
WORKDIR "$BASE_DIR"
ENV BASE_DIR="$BASE_DIR"
ENTRYPOINT ["buildbot"]
