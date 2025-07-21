# syntax=docker/dockerfile:1
ARG UID=1001
ARG VERSION=2025.06.30
ARG RELEASE=0
ARG POT_PROVIDER_VERSION=1.1.0

########################################
# bgutil-ytdlp-pot-provider unpack stage
########################################

FROM alpine:3 AS bgutil-ytdlp-pot-provider-unpacker

WORKDIR /bgutil-ytdlp-pot-provider

ARG POT_PROVIDER_VERSION
ADD https://github.com/Brainicism/bgutil-ytdlp-pot-provider/releases/download/${POT_PROVIDER_VERSION}/bgutil-ytdlp-pot-provider.zip /tmp/bgutil-ytdlp-pot-provider.zip

RUN unzip /tmp/bgutil-ytdlp-pot-provider.zip -d /client

########################################
# Final stage
# https://github.com/Brainicism/bgutil-ytdlp-pot-provider/blob/master/server/Dockerfile
########################################
FROM brainicism/bgutil-ytdlp-pot-provider:${POT_PROVIDER_VERSION} AS final

# RUN mount cache for multi-arch: https://github.com/docker/buildx/issues/549#issuecomment-1788297892
ARG TARGETARCH
ARG TARGETVARIANT

# Create user
ARG UID
RUN groupadd -g $UID $UID && \
    useradd -l -u $UID -g $UID -m -s /bin/sh -N $UID

# Create directories with correct permissions
RUN install -d -m 775 -o $UID -g 0 /download && \
    install -d -m 775 -o $UID -g 0 /licenses && \
    install -d -m 775 -o $UID -g 0 /etc/yt-dlp-plugins/bgutil-ytdlp-pot-provider

# Copy licenses (OpenShift Policy)
COPY --link --chown=$UID:0 --chmod=775 LICENSE /licenses/Dockerfile.LICENSE
COPY --link --chown=$UID:0 --chmod=775 yt-dlp/LICENSE /licenses/yt-dlp.LICENSE

# Copy BgUtils POT Provider
COPY --link --chown=$UID:0 --chmod=775 --from=bgutil-ytdlp-pot-provider-unpacker /client /etc/yt-dlp-plugins/bgutil-ytdlp-pot-provider

# ffmpeg
COPY --link --from=ghcr.io/jim60105/static-ffmpeg-upx:7.1.1 /ffmpeg /usr/bin/
COPY --link --from=ghcr.io/jim60105/static-ffmpeg-upx:7.1.1 /ffprobe /usr/bin/

# dumb-init
COPY --link --from=ghcr.io/jim60105/static-ffmpeg-upx:7.1.1 /dumb-init /usr/bin/

# Ensure the cache is not reused when installing yt-dlp
ARG RELEASE
ARG VERSION

# yt-dlp
ADD --link --chown=$UID:0 --chmod=775 https://github.com/yt-dlp/yt-dlp/releases/download/${VERSION}/yt-dlp_linux /usr/bin/yt-dlp

WORKDIR /download

VOLUME [ "/download" ]

USER $UID

STOPSIGNAL SIGINT

# Use dumb-init as PID 1 to handle signals properly
# Run POT node script in background, yt-dlp in foreground
ENTRYPOINT [ "dumb-init", "--", "sh", "-c", "node /app/build/main.js & exec yt-dlp --no-cache-dir \"$@\"", "sh" ]
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
