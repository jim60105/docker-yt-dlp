# syntax=docker/dockerfile:1
ARG UID=1001

FROM alpine:3 as final

ARG UID

RUN apk add -u --no-cache \
    # This branch follows the yt-dlp release
    -X "http://dl-cdn.alpinelinux.org/alpine/edge/community" \
    # ffmpeg is one of the dependencies of yt-dlp, so don't need to install it manually
    yt-dlp \
    # Use dumb-init to handle signals
    dumb-init

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
