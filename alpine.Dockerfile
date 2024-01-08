# syntax=docker/dockerfile:1
ARG UID=1001
ARG BUILD_VERSION=2023.12.30

FROM python:3.12-alpine as build

# RUN mount cache for multi-arch: https://github.com/docker/buildx/issues/549#issuecomment-1788297892
ARG TARGETARCH
ARG TARGETVARIANT

ARG BUILD_VERSION

WORKDIR /app

# Install under /root/.local
ENV PIP_USER="true"
ARG PIP_NO_WARN_SCRIPT_LOCATION=0
ARG PIP_ROOT_USER_ACTION="ignore"

RUN --mount=type=cache,id=pip-$TARGETARCH$TARGETVARIANT,sharing=locked,target=/root/.cache/pip \
    pip3.12 install yt-dlp==$BUILD_VERSION && \
    # Cleanup
    find "/root/.local" -name '*.pyc' -print0 | xargs -0 rm -f || true ; \
    find "/root/.local" -type d -name '__pycache__' -print0 | xargs -0 rm -rf || true ;

FROM python:3.12-alpine as final

ARG UID

RUN pip3.12 uninstall -y setuptools pip wheel && \
    rm -rf /root/.cache/pip

# Use dumb-init to handle signals
RUN apk add -u --no-cache dumb-init

# ffmpeg (6.1 is broken, so override it)
COPY --link --from=mwader/static-ffmpeg:6.1.1 /ffmpeg /usr/bin/
COPY --link --from=mwader/static-ffmpeg:6.1.1 /ffprobe /usr/bin/

# Create user
RUN addgroup -g $UID $UID && \
    adduser -g "" -D $UID -u $UID -G $UID

# Copy dist and support arbitrary user ids (OpenShift best practice)
# https://docs.openshift.com/container-platform/4.14/openshift_images/create-images.html#use-uid_create-images
COPY --chown=$UID:0 --chmod=774 \
    --from=build /root/.local /home/$UID/.local
ENV PATH="/home/$UID/.local/bin:$PATH"

# Remove these to prevent the container from executing arbitrary commands
RUN rm /bin/echo /bin/ln /bin/rm /bin/sh

# Run as non-root user
USER $UID
WORKDIR /download
VOLUME [ "/download" ]

STOPSIGNAL SIGINT
ENTRYPOINT [ "dumb-init", "--", "yt-dlp", "--no-cache-dir" ]
CMD ["--help"]