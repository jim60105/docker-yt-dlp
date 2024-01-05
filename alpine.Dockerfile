# syntax=docker/dockerfile:1

FROM python:3.12-alpine as build
ARG BUILD_VERSION

RUN pip3.12 install --no-cache-dir yt-dlp==$BUILD_VERSION && \
    pip3.12 uninstall -y setuptools pip && \
    rm -rf /root/.cache/pip

FROM build as final

# Use dumb-init to handle signals
RUN apk add --no-cache dumb-init ffmpeg

RUN mkdir -p /download && chown 1001:1001 /download
VOLUME [ "/download" ]

# Remove these to prevent the container from executing arbitrary commands
RUN rm /bin/echo /bin/ln /bin/rm /bin/sh

# Run as non-root user
USER 1001
WORKDIR /download

STOPSIGNAL SIGINT
ENTRYPOINT [ "dumb-init", "--", "/venv/bin/yt-dlp", "--no-cache-dir" ]
CMD ["--help"]
