# syntax=docker/dockerfile:1

### Python
FROM registry.access.redhat.com/ubi9/ubi-minimal AS base

ENV PYTHON_VERSION=3.11
ENV PYTHONUNBUFFERED=1
ENV PYTHONIOENCODING=UTF-8

RUN microdnf -y install python3.11 && \
    microdnf -y clean all
RUN ln -s /usr/bin/python3.11 /usr/bin/python3 && \
    ln -s /usr/bin/python3.11 /usr/bin/python

### Build image
FROM base AS build

ARG BUILD_VERSION

WORKDIR /app

RUN python3 -m venv /venv
ENV PATH="/venv/bin:$PATH"

ARG PIP_DISABLE_PIP_VERSION_CHECK=1
ARG PIP_NO_CACHE_DIR=1

RUN pip3.11 install --no-cache-dir dumb-init yt-dlp==$BUILD_VERSION && \
    pip3.11 uninstall -y setuptools pip && \
    rm -rf /root/.cache/pip

### Final image
FROM base AS final

ENV PATH="/venv/bin:$PATH"

# Copy venv
COPY --link --from=build /venv /venv

# ffmpeg
COPY --link --from=mwader/static-ffmpeg:6.1.1 /ffmpeg /usr/bin/
COPY --link --from=mwader/static-ffmpeg:6.1.1 /ffprobe /usr/local/bin/

RUN mkdir -p /download && chown 1001:1001 /download
VOLUME [ "/download" ]

# Run as non-root user
USER 1001
WORKDIR /download

STOPSIGNAL SIGINT
ENTRYPOINT [ "/venv/bin/dumb-init", "--", "/venv/bin/yt-dlp", "--no-cache-dir" ]
CMD ["--help"]
