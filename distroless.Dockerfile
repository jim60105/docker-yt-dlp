# syntax=docker/dockerfile:1
ARG VERSION=2024.04.09
ARG RELEASE=0

########################################
# Build stage
########################################
FROM python:3.12-bookworm as build

# RUN mount cache for multi-arch: https://github.com/docker/buildx/issues/549#issuecomment-1788297892
ARG TARGETARCH
ARG TARGETVARIANT

WORKDIR /app

# Install under /root/.local
ENV PIP_USER="true"
ARG PIP_NO_WARN_SCRIPT_LOCATION=0
ARG PIP_ROOT_USER_ACTION="ignore"
ARG PIP_NO_COMPILE="true"
ARG PIP_DISABLE_PIP_VERSION_CHECK="true"

ARG VERSION
RUN --mount=type=cache,id=pip-$TARGETARCH$TARGETVARIANT,sharing=locked,target=/root/.cache/pip \
    pip install -U --force-reinstall pip setuptools wheel && \
    pip install yt-dlp==$VERSION && \
    # Cleanup
    find "/root/.local" -name '*.pyc' -print0 | xargs -0 rm -f || true ; \
    find "/root/.local" -type d -name '__pycache__' -print0 | xargs -0 rm -rf || true ; \
    # Make an empty directory for final stage
    mkdir -p /newdir

########################################
# Final stage
# Distroless image use monty(1000) for non-root user
########################################
FROM al3xos/python-distroless:3.12-debian12 as final

ARG UID=1000

# Create directories with correct permissions
COPY --link --chown=$UID:0 --chmod=775 --from=build /newdir /download
COPY --link --chown=$UID:0 --chmod=775 --from=build /newdir /licenses

# ffmpeg
COPY --link --from=ghcr.io/jim60105/static-ffmpeg-upx:7.0-1 /ffmpeg /usr/bin/
COPY --link --from=ghcr.io/jim60105/static-ffmpeg-upx:7.0-1 /ffprobe /usr/bin/

# dumb-init
COPY --link --from=ghcr.io/jim60105/static-ffmpeg-upx:7.0-1 /dumb-init /usr/bin/

# Copy licenses (OpenShift Policy)
COPY --link --chown=$UID:0 --chmod=775 LICENSE /licenses/Dockerfile.LICENSE
COPY --link --chown=$UID:0 --chmod=775 yt-dlp/LICENSE /licenses/yt-dlp.LICENSE

# Copy dist and support arbitrary user ids (OpenShift best practice)
# https://docs.openshift.com/container-platform/4.14/openshift_images/create-images.html#use-uid_create-images
COPY --link --chown=$UID:0 --chmod=775 --from=build /root/.local /home/monty/.local

ENV PATH="/home/monty/.local/bin:$PATH"

WORKDIR /download

VOLUME [ "/download" ]

USER $UID

STOPSIGNAL SIGINT

# Use dumb-init as PID 1 to handle signals properly
ENTRYPOINT [ "dumb-init", "--", "yt-dlp", "--no-cache-dir" ]
CMD ["--help"]

ARG VERSION
ARG RELEASE
LABEL name="jim60105/docker-yt-dlp" \
    # Authors for yt-dlp
    vendor="yt-dlp" \
    # Maintainer for this docker image
    maintainer="jim60105" \
    # Dockerfile source repository
    url="https://github.com/jim60105/docker-yt-dlp" \
    version=${VERSION} \
    # This should be a number, incremented with each change
    release=${RELEASE} \
    io.k8s.display-name="yt-dlp" \
    summary="yt-dlp: A feature-rich command-line audio/video downloader." \
    description="yt-dlp is a feature-rich command-line audio/video downloader with support for thousands of sites. The project is a fork of youtube-dl based on the now inactive youtube-dlc. For more information about this tool, please visit the following website: https://github.com/yt-dlp/yt-dlp"
