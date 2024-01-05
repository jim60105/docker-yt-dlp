# syntax=docker/dockerfile:1

FROM alpine as final

# This branch follows the yt-dlp release
RUN echo "http://dl-cdn.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories
# Use dumb-init to handle signals
RUN apk add -U --no-cache dumb-init yt-dlp

RUN mkdir -p /download && chown 1001:1001 /download
VOLUME [ "/download" ]

# Remove these to prevent the container from executing arbitrary commands
RUN rm /bin/echo /bin/ln /bin/rm /bin/sh

# Run as non-root user
USER 1001
WORKDIR /download

STOPSIGNAL SIGINT
ENTRYPOINT [ "dumb-init", "--", "yt-dlp", "--no-cache-dir" ]
CMD ["--help"]
