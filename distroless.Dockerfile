# syntax=docker/dockerfile:1

FROM python:3.12-slim-bookworm as build

ARG BUILD_VERSION

WORKDIR /app

RUN python3.12 -m venv /venv
ENV PATH="/venv/bin:$PATH"

RUN pip3.12 install --no-cache-dir dumb-init yt-dlp==$BUILD_VERSION && \
    pip3.12 uninstall -y setuptools pip && \
    pip3.12 uninstall -y setuptools pip

# Make a directory for COPY to final (distroless has no mkdir)
RUN mkdir -p /download

FROM al3xos/python-distroless:3.12-debian12 as final

ENV PATH="/venv/bin:$PATH"

# Copy venv
COPY --link --from=build /venv /venv

# ffmpeg
COPY --link --from=mwader/static-ffmpeg:6.1.1 /ffmpeg /usr/bin/
COPY --link --from=mwader/static-ffmpeg:6.1.1 /ffprobe /usr/local/bin/

COPY --link --from=build --chown=1001:1001 /download /download
VOLUME [ "/download" ]

# Run as non-root user
USER 1001
WORKDIR /download

STOPSIGNAL SIGINT
ENTRYPOINT [ "dumb-init", "--", "/venv/bin/yt-dlp", "--no-cache-dir" ]
CMD ["--help"]
