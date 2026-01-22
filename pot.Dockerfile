# syntax=docker/dockerfile:1
ARG UID=1001
ARG VERSION=2025.11.12
ARG RELEASE=0

########################################
# folder stage
########################################
FROM alpine:3 AS folder

# Create directories with correct permissions
ARG UID
RUN install -d -m 775 -o $UID -g 0 /newdir

########################################
# Final stage
########################################
FROM docker.io/denoland/deno:debian AS final

ARG UID

# Create directories with correct permissions
COPY --chown=$UID:0 --chmod=775 --from=folder /newdir /licenses
COPY --chown=$UID:0 --chmod=775 --from=folder /newdir /etc/yt-dlp-plugins/bgutil-ytdlp-pot-provider
COPY --link --chown=$UID:0 --chmod=775 --from=folder /newdir /download
COPY --link --chown=$UID:0 --chmod=775 --from=folder /newdir /tmp

# Copy licenses (OpenShift Policy)
COPY --link --chown=$UID:0 --chmod=775 LICENSE /licenses/Dockerfile.LICENSE
COPY --link --chown=$UID:0 --chmod=775 yt-dlp/LICENSE /licenses/yt-dlp.LICENSE

# ffmpeg
COPY --link --chown=$UID:0 --chmod=775 --from=ghcr.io/jim60105/static-ffmpeg-upx:8.0 /ffmpeg /usr/bin/
COPY --link --chown=$UID:0 --chmod=775 --from=ghcr.io/jim60105/static-ffmpeg-upx:8.0 /ffprobe /usr/bin/

# dumb-init
COPY --link --chown=$UID:0 --chmod=775 --from=ghcr.io/jim60105/static-ffmpeg-upx:8.0 /dumb-init /usr/bin/

# BgUtil POT provider
COPY --link --chown=$UID:0 --chmod=775 --from=ghcr.io/jim60105/bgutil-pot:latest /bgutil-pot /usr/bin/

# BgUtil POT client
COPY --link --chown=$UID:0 --chmod=775 --from=ghcr.io/jim60105/bgutil-pot:latest /client /etc/yt-dlp-plugins/bgutil-ytdlp-pot-provider

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
