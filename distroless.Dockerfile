# syntax=docker/dockerfile:1

FROM python:3.12-bookworm as build

# RUN mount cache for multi-arch: https://github.com/docker/buildx/issues/549#issuecomment-1788297892
ARG TARGETARCH
ARG TARGETVARIANT

ARG BUILD_VERSION

WORKDIR /app

# Install under /root/.local
ENV PIP_USER="true"

RUN --mount=type=cache,id=pip-$TARGETARCH$TARGETVARIANT,sharing=locked,target=/root/.cache/pip \
    pip3.12 install dumb-init yt-dlp==$BUILD_VERSION && \
    # Cleanup
    find "/root/.local" -name '*.pyc' -print0 | xargs -0 rm -f || true ; \
    find "/root/.local" -type d -name '__pycache__' -print0 | xargs -0 rm -rf || true ;

# Distroless image use monty(1000) for non-root user
FROM al3xos/python-distroless:3.12-debian12 as final

# ffmpeg
COPY --link --from=mwader/static-ffmpeg:6.1.1 /ffmpeg /usr/bin/
COPY --link --from=mwader/static-ffmpeg:6.1.1 /ffprobe /usr/bin/

# Copy dist and support arbitrary user ids (OpenShift best practice)
# https://docs.openshift.com/container-platform/4.14/openshift_images/create-images.html#use-uid_create-images
COPY --chown=1000:0 --chmod=774 \
    --from=build /root/.local /home/monty/.local
ENV PATH="/home/monty/.local/bin:$PATH"

WORKDIR /download
VOLUME [ "/download" ]

STOPSIGNAL SIGINT
ENTRYPOINT [ "dumb-init", "--", "yt-dlp", "--no-cache-dir" ]
CMD ["--help"]
