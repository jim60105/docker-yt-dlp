# syntax=docker/dockerfile:1
ARG UID=1001

FROM alpine:3 as final

ARG UID

RUN apk add -u --no-cache \
    # These branches follows the yt-dlp release
    -X "https://dl-cdn.alpinelinux.org/alpine/edge/main" \
    -X "https://dl-cdn.alpinelinux.org/alpine/edge/community" \
    # ffmpeg is one of the dependencies of yt-dlp, so don't need to install it manually
    yt-dlp \
    # Use dumb-init to handle signals
    dumb-init

# ffmpeg (6.1 is broken, so override it)
COPY --link --from=mwader/static-ffmpeg:6.1.1 /ffmpeg /usr/bin/
COPY --link --from=mwader/static-ffmpeg:6.1.1 /ffprobe /usr/bin/

# Create user
RUN addgroup -g $UID $UID && \
    adduser -H -g "" -D $UID -u $UID -G $UID

# Remove these to prevent the container from executing arbitrary commands
RUN rm /bin/echo /bin/ln /bin/rm /bin/sh

# Run as non-root user
USER $UID
WORKDIR /download
VOLUME [ "/download" ]

STOPSIGNAL SIGINT
ENTRYPOINT [ "dumb-init", "--", "yt-dlp", "--no-cache-dir" ]
CMD ["--help"]