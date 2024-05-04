# syntax=docker/dockerfile:1
ARG UID=1001
ARG VERSION=EDGE
ARG RELEASE=0

########################################
# Compress stage
########################################
FROM alpine:3 as compress

# RUN mount cache for multi-arch: https://github.com/docker/buildx/issues/549#issuecomment-1788297892
ARG TARGETARCH
ARG TARGETVARIANT

# Compress ffmpeg and ffprobe
# UPX skip small files: https://github.com/upx/upx/blob/5bef96806860382395d9681f3b0c69e0f7e853cf/src/p_unix.cpp#L80
# UPX skip large files: https://github.com/upx/upx/blob/b0dc48316516d236664dfc5f1eb5f2de00fc0799/src/conf.h#L134
RUN --mount=type=cache,id=apk-$TARGETARCH$TARGETVARIANT,sharing=locked,target=/var/cache/apk \
    --mount=from=mwader/static-ffmpeg:7.0-1,source=/ffmpeg,target=/tmp/ffmpeg,rw \
    --mount=from=mwader/static-ffmpeg:7.0-1,source=/ffprobe,target=/tmp/ffprobe,rw \
    apk update && apk add -u \
    -X "https://dl-cdn.alpinelinux.org/alpine/edge/community" \
    # Use upx to compress the ffmpeg binary
    upx dumb-init && \
    cp /tmp/ffmpeg / && \
    cp /tmp/ffprobe / && \
    upx --best --lzma /ffmpeg || true; \
    upx --best --lzma /ffprobe || true; \
    upx --best --lzma /usr/bin/dumb-init || true; \
    apk del upx

########################################
# Final stage
########################################
FROM alpine:3 as final

# RUN mount cache for multi-arch: https://github.com/docker/buildx/issues/549#issuecomment-1788297892
ARG TARGETARCH
ARG TARGETVARIANT

# Create user
ARG UID
RUN addgroup -g $UID $UID && \
    adduser -H -g "" -D $UID -u $UID -G $UID

# Create directories with correct permissions
RUN install -d -m 775 -o $UID -g 0 /download && \
    install -d -m 775 -o $UID -g 0 /licenses

# Copy licenses (OpenShift Policy)
COPY --link --chown=$UID:0 --chmod=775 LICENSE /licenses/Dockerfile.LICENSE
COPY --link --chown=$UID:0 --chmod=775 yt-dlp/LICENSE /licenses/yt-dlp.LICENSE

RUN --mount=type=cache,id=apk-$TARGETARCH$TARGETVARIANT,sharing=locked,target=/var/cache/apk \
    --mount=from=compress,source=/ffmpeg,target=/ffmpeg,rw \
    --mount=from=compress,source=/ffprobe,target=/ffprobe,rw \
    --mount=from=compress,source=/usr/bin/dumb-init,target=/dumb-init,rw \
    apk update && apk add -u \
    # These branches follows the yt-dlp release
    -X "https://dl-cdn.alpinelinux.org/alpine/edge/main" \
    -X "https://dl-cdn.alpinelinux.org/alpine/edge/community" \
    yt-dlp && \
    # Copy the compressed ffmpeg and ffprobe and overwrite the apk installed ones
    cp /ffmpeg /usr/bin/ && \
    cp /ffprobe /usr/bin/ && \
    cp /dumb-init /usr/bin/

# Remove these to prevent the container from executing arbitrary commands
RUN rm /bin/echo /bin/ln /bin/rm /bin/sh

WORKDIR /app

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
